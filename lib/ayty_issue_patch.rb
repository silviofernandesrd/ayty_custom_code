##### AYTYCRM - Silvio Fernandes #####
require_dependency 'issue'

module AytyIssuePatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      # remove a validacao de presenca da prioridade
      _validators.delete(:priority)
      _validate_callbacks.each do |callback|
        if callback.raw_filter.respond_to? :attributes
          callback.raw_filter.attributes.delete :priority
        end
      end

      # metodo para ajustar as prioridades dos usuarios Ayty
      before_save :ayty_priority

      # Responsavel de cada area
      belongs_to :assigned_to_bd, :class_name => 'User', :foreign_key => 'assigned_to_bd_id'
      belongs_to :assigned_to_net, :class_name => 'User', :foreign_key => 'assigned_to_net_id'
      belongs_to :assigned_to_test, :class_name => 'User', :foreign_key => 'assigned_to_test_id'
      belongs_to :assigned_to_aneg, :class_name => 'User', :foreign_key => 'assigned_to_aneg_id'
      belongs_to :assigned_to_areq, :class_name => 'User', :foreign_key => 'assigned_to_areq_id'
      belongs_to :assigned_to_inf, :class_name => 'User', :foreign_key => 'assigned_to_inf_id'

      # ayty manager priority
      belongs_to :ayty_manager_priority_user, :class_name => 'User', :foreign_key => 'ayty_manager_priority_user_id'

      # acrescentado foreing_key e primary_key para funcionar o relacionamento
      # dependent plugin redmine_time_tracker
      has_many :time_trackers, :foreign_key => :issue_id

      delegate :ayty_access_level_id, :ayty_access_level_id=, :to => :current_journal, :allow_nil => true

      safe_attributes 'ayty_access_level_id',
                      # responsaveis
                      'assigned_to_bd_id',
                      'assigned_to_net_id',
                      'assigned_to_test_id',
                      'assigned_to_aneg_id',
                      'assigned_to_areq_id',
                      'assigned_to_inf_id',
                      # ayty manager priority
                      'ayty_manager_priority_user_id',
                      'ayty_manager_priority_date'


      scope :ayty_issues_priority, ->(user) { joins(:priority).
                                                  where(:assigned_to_id => user).
                                                  order("#{IssuePriority.table_name}.position") }

      scope :ayty_issues_responsible_open, ->(user) { where("(#{Issue.table_name}.assigned_to_bd_id = :u
                                                           or #{Issue.table_name}.assigned_to_net_id = :u
                                                           or #{Issue.table_name}.assigned_to_test_id = :u
                                                           or #{Issue.table_name}.assigned_to_aneg_id = :u
                                                           or #{Issue.table_name}.assigned_to_areq_id = :u
                                                           or #{Issue.table_name}.assigned_to_inf_id = :u)
                                                           and (
                                                           (#{Issue.table_name}.status_id in (14,25) and
                                                           #{Issue.table_name}.updated_on > DATEADD(DD, -30, GETDATE()))
                                                           or #{Issue.table_name}.status_id not in (14,25))
                                                           and #{Issue.table_name}.assigned_to_id <> :u", {:u => user}).
                                                          order("CASE #{Issue.table_name}.status_id
                                                            WHEN 23 THEN 1
                                                            WHEN 22 THEN 2
                                                            WHEN 32 THEN 3
                                                            WHEN 31 THEN 4
                                                            WHEN 8 THEN 5
                                                            WHEN 9 THEN 6
                                                            WHEN 11 THEN 7
                                                            WHEN 13 THEN 8
                                                            WHEN 34 THEN 9
                                                            WHEN 25 THEN 10
                                                            WHEN 14  THEN 11
                                                          ELSE 12 END") }

      scope :ayty_issues_responsible_closed, ->(user) { joins(:status).
                                                            where("(#{Issue.table_name}.assigned_to_bd_id = :u
                                                           or #{Issue.table_name}.assigned_to_net_id = :u
                                                           or #{Issue.table_name}.assigned_to_test_id = :u
                                                           or #{Issue.table_name}.assigned_to_aneg_id = :u
                                                           or #{Issue.table_name}.assigned_to_areq_id = :u
                                                           or #{Issue.table_name}.assigned_to_inf_id = :u)
                                                           and #{Issue.table_name}.updated_on > DATEADD(DD, -3, GETDATE())
                                                           and #{IssueStatus.table_name}.is_closed = :c", {:u => user, :c => true}).
                                                            order("#{Issue.table_name}.id") }

      scope :ayty_issues_watcher, ->(user) { joins(:watchers).
                                                 where("#{Watcher.table_name}.watchable_type = 'Issue'
                                                and #{Watcher.table_name}.user_id = :u", {:u => user}) }

      scope :ayty_issues_time_tracker_pendings, ->(user) { joins(:time_trackers).
                                                               where("#{TimeTracker.table_name}.user_id = :u", {:u => user}) }

      scope :ayty_exclude_issues_id, ->(issues_id) { where("#{Issue.table_name}.id not in (#{issues_id})") }

      # Faz chamada para uma procedure depois de salvar
      # procedure spr_ayty_validate_update_issue_after
      after_update :ayty_call_procedure_after_save

      # Faz chamada para uma procedure antes de salvar
      # procedure spr_ayty_validate_update_issue_before
      validate :ayty_call_procedure_before_save

      # faz um alias para salvar os dados dos campos personalizados antes das alteracoes
      # para depois poder enviar estes dados para uma procedure spr_ayty_validate_update_issue_before
      alias_method_chain :init_journal, :ayty_before_changes

      alias_method_chain :notified_users, :ayty_filter_notifieds

      # atributo para salvar os dados dos apontamentos antes de salvar
      # este dados sao utilizados para enviar para uma procedure spr_ayty_validate_update_issue_before
      attr_accessor :ayty_before_time_entry

      # Acrescentado validacao para nao mostrar o campo caso o nivel de acesso do usuario tenha ativo
      # a flag ayty_deny_edit e o campo também.
      alias_method_chain :editable_custom_field_values, :ayty_custom_rule

      # metodo para filtrar nivel de acesso
      alias_method_chain :visible_custom_field_values, :ayty_custom_rule

      # remover esta customizacao quando migrar para versao 3.3.0
      # FIX: https://www.redmine.org/issues/13654
      alias_method_chain :validate_issue, :ayty_fix_parent_associations

      alias_method_chain :copy_from, :clean_fields

    end
  end

  def copy_from_with_clean_fields(arg, options={})
    if arg.is_a?(Issue)
      issue = arg.is_a?(Issue) ? arg : Issue.visible.find(arg)

      issue.due_date = nil
      issue.assigned_to_bd_id = nil
      issue.assigned_to_net_id = nil
      issue.assigned_to_aneg_id = nil
      issue.assigned_to_areq_id = nil
      issue.assigned_to_inf_id = nil
      issue.assigned_to_test_id = nil
      issue.ayty_manager_priority_user_id = nil
      issue.ayty_manager_priority_date = nil
      issue.qt_reproof_internal = nil
      issue.qt_reproof_external = nil
      issue.qt_technical_homologation_repproval = nil
      issue.qt_business_homologation_repproval = nil
      issue.qt_test_repproval = nil
      issue.qt_client_homologation_repproval = nil
      issue.dt_start_desenv = nil
      issue.dt_finish_desenv = nil
      issue.dt_start_wait_test = nil
      issue.dt_start_test = nil
      issue.dt_finish_test = nil
      issue.dt_start_homologation_tech = nil
      issue.dt_finish_homologation_tech = nil
      issue.dt_finish_homologation_tech_last = nil
      issue.dt_start_aneg = nil
      issue.dt_finish_aneg = nil
      issue.dt_finish_aneg_last = nil
      issue.dt_delivery_client = nil
      issue.dt_delivery_client_last = nil
      issue.dt_finish_desenv_transitional = nil
      issue.dt_client_return = nil
      issue.dt_client_return_last = nil
      issue.dt_queue_enter = nil
      issue.was_waiting_information_desenv = nil
      issue.was_sent_techical_homologacion = nil
      issue.was_sent_business_homologacion = nil
      issue.was_client_delivery_delayed = nil
      issue.was_tested = nil
      issue.was_client_delivery_disapproved = nil
      issue.was_aneg_delivery_delayed = nil
      issue.was_delivery_delayed_client_after_disapproved = nil

      issue.custom_field_values.reject! {|cfv| cfv.custom_field.clear_value_to_copy? }

      copy_from_without_clean_fields(issue, options)
    end

  end

  #override
  # remover esta customizacao quando migrar para versao 3.3.0
  # FIX: https://www.redmine.org/issues/13654
  def validate_issue_with_ayty_fix_parent_associations
    if due_date && start_date && (start_date_changed? || due_date_changed?) && due_date < start_date
      errors.add :due_date, :greater_than_start_date
    end

    if start_date && start_date_changed? && soonest_start && start_date < soonest_start
      errors.add :start_date, :earlier_than_minimum_start_date, :date => format_date(soonest_start)
    end

    if fixed_version
      if !assignable_versions.include?(fixed_version)
        errors.add :fixed_version_id, :inclusion
      elsif reopening? && fixed_version.closed?
        errors.add :base, I18n.t(:error_can_not_reopen_issue_on_closed_version)
      end
    end

    # Checks that the issue can not be added/moved to a disabled tracker
    if project && (tracker_id_changed? || project_id_changed?)
      unless project.trackers.include?(tracker)
        errors.add :tracker_id, :inclusion
      end
    end

    # Checks parent issue assignment
    if @invalid_parent_issue_id.present?
      errors.add :parent_issue_id, :invalid
    elsif @parent_issue
      if !valid_parent_project?(@parent_issue)
        errors.add :parent_issue_id, :invalid
      # remover esta customizacao quando migrar para versao 3.3.0
      # FIX: https://www.redmine.org/issues/13654
      #elsif (@parent_issue != parent) && (all_dependent_issues.include?(@parent_issue) || @parent_issue.all_dependent_issues.include?(self))
      elsif (@parent_issue != parent) && (self.would_reschedule?(@parent_issue) || @parent_issue.self_and_ancestors.any? {|a| a.relations_from.any? {|r| r.relation_type == IssueRelation::TYPE_PRECEDES && r.issue_to.would_reschedule?(self)}})
        errors.add :parent_issue_id, :invalid
      elsif !new_record?
        # moving an existing issue
        if move_possible?(@parent_issue)
          # move accepted
        else
          errors.add :parent_issue_id, :invalid
        end
      end
    end
  end

  # remover esta customizacao quando migrar para versao 3.3.0
  # FIX: https://www.redmine.org/issues/13654
  # Returns true if this issue blocks the other issue, otherwise returns false
  def blocks?(other)
    all = [self]
    last = [self]
    while last.any?
      current = last.map {|i| i.relations_from.where(:relation_type => IssueRelation::TYPE_BLOCKS).map(&:issue_to)}.flatten.uniq
      current -= last
      current -= all
      return true if current.include?(other)
      last = current
      all += last
    end
    false
  end

  # remover esta customizacao quando migrar para versao 3.3.0
  # FIX: https://www.redmine.org/issues/13654
  # Returns true if the other issue might be rescheduled if the start/due dates of this issue change
  def would_reschedule?(other)
    all = [self]
    last = [self]
    while last.any?
      current = last.map {|i|
        i.relations_from.where(:relation_type => IssueRelation::TYPE_PRECEDES).map(&:issue_to) +
        i.leaves.to_a +
        i.ancestors.map {|a| a.relations_from.where(:relation_type => IssueRelation::TYPE_PRECEDES).map(&:issue_to)}
      }.flatten.uniq
      current -= last
      current -= all
      return true if current.include?(other)
      last = current
      all += last
    end
    false
  end

  #override
  #para excluir os usuarios que nao tenham acesso de acordo com o acesso de quem esta abrindo o ticket
  # Returns the users that should be notified
  def notified_users_with_ayty_filter_notifieds
    notified = []
    # Author and assignee are always notified unless they have been
    # locked or don't want to be notified
    notified << author if author

    if assigned_to_was
      notified += (assigned_to_was.is_a?(Group) ? assigned_to_was.users : [assigned_to_was])
    end
    notified = notified.select {|u| u.active? && u.notify_about?(self)}

    notified += project.notified_users
    notified.uniq!
    # Remove users that can not view the issue
    notified.reject! {|user| !visible?(user)}

    # remove usuarios que tenham nivel de acesso menor que o nivel de acesso de quem esta logado
    if User.current && User.current.ayty_access_level
      notified.reject! {|user| user.ayty_access_level.level < User.current.ayty_access_level.level}
    end

    # colocado assigned_to para depois do filtro da ayty, para pode enviar email para o cliente
    if assigned_to
      notified += (assigned_to.is_a?(Group) ? assigned_to.users : [assigned_to])
    end

    notified.uniq!

    notified
  end

  # alias que cria a variavel com os valores antes das alteracoes
  def init_journal_with_ayty_before_changes(user, notes = "")

    # cria a variavel
    @ayty_custom_values_before_change = self.custom_field_values.inject({}) do |h, c|
      h[c.custom_field_id] = c.value
      h
    end

    # faz chamada para o metodo original para rodar os demais codigos
    init_journal_without_ayty_before_changes(user, notes)

  end

  # override
  def editable_custom_field_values_with_ayty_custom_rule(user=nil)
    visible_custom_field_values(user).reject do |value|
      read_only_attribute_names(user).include?(value.custom_field_id.to_s) || (value.custom_field.ayty_access_level.level > User.current.ayty_access_level.level) || (!User.current.ayty_is_user_ayty? && value.custom_field.ayty_deny_edit?)
    end
  end

  # override
  def visible_custom_field_values_with_ayty_custom_rule(user=nil)
    user_real = user || User.current
    custom_field_values.select do |value|
      value.custom_field.visible_by?(project, user_real) && value.custom_field.ayty_access_level.level <= User.current.ayty_access_level.level
    end
  end

  # Override para traze somente usuario Ayty
  def ayty_assignable_users(ayty_user=false, refresh=false, append_assigned_to_responsibles=false)
    users = project.ayty_assignable_users(ayty_user, refresh).to_a
    users << author if author
    users << assigned_to if assigned_to

    # Acrescentado funcionalidade para mostrar usuarios responsaveis, caso o mesmo nao esteja no combo e o status permita isso
    if append_assigned_to_responsibles
      if status.ayty_assignable_responsible
        users << assigned_to_bd if assigned_to_bd
        users << assigned_to_net if assigned_to_net
        users << assigned_to_test if assigned_to_test
        users << assigned_to_aneg if assigned_to_aneg
        users << assigned_to_areq if assigned_to_areq
        users << assigned_to_inf if assigned_to_inf
      end
    end

    users.uniq.sort
  end

  # metodo para ajustar as prioridades dos usuarios Ayty
  def ayty_priority
    # somente usuarios ayty
    # tickets abertos
    # com alteracao de atribuido para
    if self.assigned_to && self.status
      if self.assigned_to.ayty_is_user_ayty? && !self.status.is_closed && self.assigned_to_id_changed?
        assigned_to_issues = Issue.visible.open.joins(:priority).where(:assigned_to_id => (self.assigned_to)).order("#{IssuePriority.table_name}.position")
        # se tiver ticket associado pega a prioridade posterior a mais alta associada
        # senao associa a primeira prioridade disponivel
        if assigned_to_issues.count > 0
          self.priority = assigned_to_issues.last.priority.ayty_get_next_priority
        else
          self.priority = IssuePriority.ayty_get_first_priority
        end
      end
    end

    # caso nao seja setado nenhuma prioridade, atribui a primeira disponivel
    if self.priority.nil?
      self.priority = IssuePriority.ayty_get_first_priority
    end
  end

  def ayty_get_value_by_custom_field_name(custom_field_name, default_value="")
    custom_value_detected = self.custom_field_values.detect { |v| v.custom_field.name == custom_field_name }
    if custom_value_detected
      if custom_value_detected.value
        unless custom_value_detected.value.empty?
          return ayty_show_value(custom_value_detected)
        end
      end
    end
    return default_value
  end

  # Metodo utilizado para recuperar a Data da ultima atualizacao de um campo customizavel
  def ayty_get_last_modification_by_custom_field_name(custom_field_name)
    journals_finded = self.journals.find_all { |v| v if v.details.detect { |x| x.custom_field.name == custom_field_name if x.custom_field } }
    if journals_finded.any?
      ayty_show_value(journals_finded.last.created_on)
    end
  end

  # Replicado metodo para retornar as horas gastas de um determinado usuario no ticket em questao
  def ayty_spent_hours_by_user (user)
    @ayty_spent_hours_by_user ||= time_entries.where(:user => user).sum(:hours) || 0
  end

  # metodo para tratamento antes da chamada da procedure
  def ayty_call_procedure_after_save

    assigned_to_id_changed = self.changes["assigned_to_id"]
    status_id_changed = self.changes["status_id"]

    if assigned_to_id_changed or status_id_changed

      # variaveis com valores null como default
      assigned_to_id_new_parsed = 'null'
      assigned_to_id_old_parsed = 'null'
      assigned_to_ayty_role_id_new_parsed = 'null'
      assigned_to_ayty_role_id_old_parsed = 'null'
      status_id_new_parsed = 'null'
      status_id_old_parsed = 'null'

      # valida se houve alteracao no atribuido para e separa os valores novo e antigo
      if assigned_to_id_changed
        if assigned_to_id_changed.any?
          assigned_to_id_new_parsed = assigned_to_id_changed.last unless assigned_to_id_changed.last.nil?
          assigned_to_ayty_role_id_new_parsed = self.assigned_to.ayty_role_id.nil? ? 'null' : self.assigned_to.ayty_role_id if self.assigned_to
          assigned_to_id_old_parsed = assigned_to_id_changed.first if assigned_to_id_changed.first
          if assigned_to_id_old_parsed && assigned_to_id_old_parsed != 'null'
            if user_old = User.find(assigned_to_id_old_parsed)
              assigned_to_ayty_role_id_old_parsed = user_old.ayty_role_id.nil? ? 'null' : user_old.ayty_role_id
            end
          end
        end
      end

      # valida se houve alteracao no status e separa os valores novo e antigo
      if status_id_changed
        if status_id_changed.any?
          status_id_new_parsed = status_id_changed.last
          status_id_old_parsed = status_id_changed.first if status_id_changed.first
        end
      end

      issue_id_parsed = self.id.nil? ? 'null' : self.id

      # responsavel de infra
      assigned_to_inf_id_parsed = self.assigned_to_inf_id.nil? ? 'null' : self.assigned_to_inf_id

      user_current_parsed = User.current.nil? ? 'null' : User.current.id
      user_current_ayty_role_id_parsed = User.current.ayty_role_id.nil? ? 'null' : User.current.ayty_role_id


      # status pos entrega - campo customizavel
      cf_status_post_delivery = self.ayty_get_value_by_custom_field_name('Status pós-Entrega', '')

      # executa procedure
      ActiveRecord::Base.connection.exec_query("exec spr_ayty_validate_update_issue_after
                                                    @issue_id = #{issue_id_parsed},
                                                    @assigned_to_id_old = #{assigned_to_id_old_parsed},
                                                    @assigned_to_ayty_role_id_old = #{assigned_to_ayty_role_id_old_parsed},
                                                    @assigned_to_id = #{assigned_to_id_new_parsed},
                                                    @assigned_to_ayty_role_id = #{assigned_to_ayty_role_id_new_parsed},
                                                    @status_id_old = #{status_id_old_parsed},
                                                    @status_id = #{status_id_new_parsed},
                                                    @assigned_to_inf_id = #{assigned_to_inf_id_parsed},
                                                    @cf_status_post_delivery = '#{cf_status_post_delivery}',
                                                    @current_user_id = #{user_current_parsed},
                                                    @current_user_ayty_role_id = #{user_current_ayty_role_id_parsed}")
    end

  end

  # metodo para tratamento antes da chamada da procedure
  def ayty_call_procedure_before_save

    issue_id_parsed = self.id.nil? ? 'null' : self.id

    assigned_to_id_valid = self.assigned_to_id.nil? ? 'null' : self.assigned_to_id
    assigned_to_id_parsed = assigned_to_id_valid
    assigned_to_id_old_parsed = self.assigned_to_id_was.nil? ? 'null' : self.assigned_to_id_was

    assigned_to_ayty_role_id_parsed = 'null'
    assigned_to_ayty_role_id_parsed = self.assigned_to.ayty_role_id.nil? ? 'null' : self.assigned_to.ayty_role_id if self.assigned_to

    assigned_to_ayty_role_id_old_parsed = 'null'
    if assigned_to_id_old_parsed != 'null'
      if user_old = User.find(assigned_to_id_old_parsed)
        assigned_to_ayty_role_id_old_parsed = user_old.ayty_role_id.nil? ? 'null' : user_old.ayty_role_id
      end
    end

    status_id_valid = self.status_id.nil? ? 'null' : self.status_id
    status_id_parsed = status_id_valid
    status_id_old_parsed = self.status_id_was.nil? ? 'null' : self.status_id_was

    assigned_to_bd_id_parsed = self.assigned_to_bd_id.nil? ? 'null' : self.assigned_to_bd_id
    assigned_to_net_id_parsed = self.assigned_to_net_id.nil? ? 'null' : self.assigned_to_net_id
    assigned_to_test_id_parsed = self.assigned_to_test_id.nil? ? 'null' : self.assigned_to_test_id
    assigned_to_areq_id_parsed = self.assigned_to_areq_id.nil? ? 'null' : self.assigned_to_areq_id
    assigned_to_aneg_id_parsed = self.assigned_to_aneg_id.nil? ? 'null' : self.assigned_to_aneg_id
    assigned_to_inf_id_parsed = self.assigned_to_inf_id.nil? ? 'null' : self.assigned_to_inf_id
    fixed_version_id_parsed = self.fixed_version_id.nil? ? 'null' : self.fixed_version_id
    due_date_parsed = self.due_date.nil? ? '' : self.due_date

    if @current_journal
      notes_parsed = @current_journal.notes.nil? ? '' : @current_journal.notes.gsub("'", "\\\\''")
    end

    user_current_parsed = User.current.nil? ? 'null' : User.current.id
    user_current_ayty_role_id_parsed = User.current.ayty_role_id.nil? ? 'null' : User.current.ayty_role_id


    cf_estimation_bd_old = ''
    cf_estimation_sys_old = ''
    cf_estimation_sys_col_old = ''
    cf_estimation_inf_old = ''
    cf_remainder_time_bd_old = ''
    cf_remainder_time_sys_old = ''
    cf_remainder_time_sys_col_old = ''
    cf_remainder_time_inf_old = ''

    if @ayty_custom_values_before_change
      cf_estimation_bd_old = regex_is_number?(@ayty_custom_values_before_change[29]) ? ayty_show_value(@ayty_custom_values_before_change[29].to_f) : ""
      cf_estimation_sys_old = regex_is_number?(@ayty_custom_values_before_change[30]) ? ayty_show_value(@ayty_custom_values_before_change[30].to_f) : ""
      cf_estimation_sys_col_old = regex_is_number?(@ayty_custom_values_before_change[54]) ? ayty_show_value(@ayty_custom_values_before_change[54].to_f) : ""
      cf_estimation_inf_old = regex_is_number?(@ayty_custom_values_before_change[34]) ? ayty_show_value(@ayty_custom_values_before_change[34].to_f) : ""
      cf_remainder_time_bd_old = regex_is_number?(@ayty_custom_values_before_change[58]) ? ayty_show_value(@ayty_custom_values_before_change[58].to_f) : ""
      cf_remainder_time_sys_old = regex_is_number?(@ayty_custom_values_before_change[59]) ? ayty_show_value(@ayty_custom_values_before_change[59].to_f) : ""
      cf_remainder_time_sys_col_old = regex_is_number?(@ayty_custom_values_before_change[61]) ? ayty_show_value(@ayty_custom_values_before_change[61].to_f) : ""
      cf_remainder_time_inf_old = regex_is_number?(@ayty_custom_values_before_change[65]) ? ayty_show_value(@ayty_custom_values_before_change[65].to_f) : ""
    end


    cf_request_type = self.ayty_get_value_by_custom_field_name('Tipo de Solicitação', '')
    cf_solution_type = self.ayty_get_value_by_custom_field_name('Tipo de Solução', '')
    cf_estimation_bd = self.ayty_get_value_by_custom_field_name('Estimativa BD - hr', '')
    cf_estimation_sys = self.ayty_get_value_by_custom_field_name('Estimativa SIS - hr', '')
    cf_estimation_sys_col = self.ayty_get_value_by_custom_field_name('Estimativa SIS Colab - hr', '')
    cf_estimation_inf = self.ayty_get_value_by_custom_field_name('Estimativa Infra - hr', '')
    cf_remainder_time_bd  = self.ayty_get_value_by_custom_field_name('Tempo Restante BD', '')
    cf_remainder_time_sys = self.ayty_get_value_by_custom_field_name('Tempo Restante SIS', '')
    cf_remainder_time_sys_col = self.ayty_get_value_by_custom_field_name('Tempo Restante SIS Colab', '')
    cf_remainder_time_inf = self.ayty_get_value_by_custom_field_name('Tempo Restante Infra', '')
    cf_quality_ticket_to_reach_areq = self.ayty_get_value_by_custom_field_name('Quality Tkt ao chegar pro AREQ', '')
    cf_quality_ticket_to_reach_des = self.ayty_get_value_by_custom_field_name('Quality Tkt ao chegar pra DES', '')
    cf_release_general_internal = self.ayty_get_value_by_custom_field_name('Release Geral - Interno', '')
    cf_release_col_internal = self.ayty_get_value_by_custom_field_name('Release Colab - Interno', '')
    cf_status_post_delivery = self.ayty_get_value_by_custom_field_name('Status pós-Entrega', '')
    cf_instructions_to_deploy = self.ayty_get_value_by_custom_field_name('Instruções para Deploy', '')
    cf_law_of_good = self.ayty_get_value_by_custom_field_name('Lei do Bem', '')

    time_entry_hours = ''
    time_entry_spent_on = ''
    time_entry_comments = ''
    time_entry_activity_id = 'null'
    time_entry_ayty_time_entry_type_id = 'null'

    if ayty_before_time_entry
      time_entry_hours = ayty_show_value(ayty_before_time_entry.hours.to_f) if ayty_before_time_entry.hours
      time_entry_spent_on = ayty_before_time_entry.spent_on if ayty_before_time_entry.spent_on
      time_entry_comments = ayty_before_time_entry.comments if ayty_before_time_entry.comments
      time_entry_activity_id = ayty_before_time_entry.activity_id if ayty_before_time_entry.activity_id
      time_entry_ayty_time_entry_type_id = ayty_before_time_entry.ayty_time_entry_type_id if ayty_before_time_entry.ayty_time_entry_type_id
    end

    # executa a procedure e pega o resultado
    result = ActiveRecord::Base.connection.exec_query("exec spr_ayty_validate_update_issue_before
                                                          @issue_id = #{issue_id_parsed},
                                                          @assigned_to_id_old = #{assigned_to_id_old_parsed},
                                                          @assigned_to_ayty_role_id_old = #{assigned_to_ayty_role_id_old_parsed},
                                                          @assigned_to_id = #{assigned_to_id_parsed},
                                                          @assigned_to_ayty_role_id = #{assigned_to_ayty_role_id_parsed},
                                                          @status_id_old = #{status_id_old_parsed},
                                                          @status_id = #{status_id_parsed},
                                                          @assigned_to_bd_id = #{assigned_to_bd_id_parsed},
                                                          @assigned_to_net_id = #{assigned_to_net_id_parsed},
                                                          @assigned_to_test_id = #{assigned_to_test_id_parsed},
                                                          @assigned_to_areq_id = #{assigned_to_areq_id_parsed},
                                                          @assigned_to_aneg_id = #{assigned_to_aneg_id_parsed},
                                                          @assigned_to_inf_id = #{assigned_to_inf_id_parsed},
                                                          @fixed_version_id = #{fixed_version_id_parsed},
                                                          @due_date = '#{due_date_parsed}',
                                                          @cf_request_type = '#{cf_request_type}',
                                                          @cf_solution_type = '#{cf_solution_type}',
                                                          @cf_estimation_bd_old = '#{cf_estimation_bd_old}',
                                                          @cf_estimation_bd = '#{cf_estimation_bd}',
                                                          @cf_estimation_sys_old = '#{cf_estimation_sys_old}',
                                                          @cf_estimation_sys = '#{cf_estimation_sys}',
                                                          @cf_estimation_sys_col_old = '#{cf_estimation_sys_col_old}',
                                                          @cf_estimation_sys_col = '#{cf_estimation_sys_col}',
                                                          @cf_estimation_inf_old = '#{cf_estimation_inf_old}',
                                                          @cf_estimation_inf = '#{cf_estimation_inf}',
                                                          @cf_remainder_time_bd_old = '#{cf_remainder_time_bd_old}',
                                                          @cf_remainder_time_bd = '#{cf_remainder_time_bd}',
                                                          @cf_remainder_time_sys_old = '#{cf_remainder_time_sys_old}',
                                                          @cf_remainder_time_sys = '#{cf_remainder_time_sys}',
                                                          @cf_remainder_time_sys_col_old = '#{cf_remainder_time_sys_col_old}',
                                                          @cf_remainder_time_sys_col = '#{cf_remainder_time_sys_col}',
                                                          @cf_remainder_time_inf_old = '#{cf_remainder_time_inf_old}',
                                                          @cf_remainder_time_inf = '#{cf_remainder_time_inf}',
                                                          @cf_quality_ticket_to_reach_areq = '#{cf_quality_ticket_to_reach_areq}',
                                                          @cf_quality_ticket_to_reach_des = '#{cf_quality_ticket_to_reach_des}',
                                                          @cf_release_general_internal = '#{cf_release_general_internal}',
                                                          @cf_release_col_internal = '#{cf_release_col_internal}',
                                                          @cf_status_post_delivery = '#{cf_status_post_delivery}',
                                                          @cf_instructions_to_deploy = '#{cf_instructions_to_deploy}',
                                                          @notes = '#{notes_parsed}',
                                                          @current_user_id = #{user_current_parsed},
                                                          @current_user_ayty_role_id = #{user_current_ayty_role_id_parsed},
                                                          @time_entry_hours = '#{time_entry_hours}',
                                                          @time_entry_spent_on = '#{time_entry_spent_on}',
                                                          @time_entry_comments = '#{time_entry_comments}',
                                                          @time_entry_activity_id = #{time_entry_activity_id},
                                                          @time_entry_time_entry_type_id = #{time_entry_ayty_time_entry_type_id},
                                                          @cf_law_of_good = '#{cf_law_of_good}'
                                                      ")

    # valida retorno
    if result
      validates = result.first["validates"]
      if validates
        # se o retorno for diferente de OK
        # prepara o resultado recebido para exibir para o usuario
        unless validates == "OK"
          validates_content = validates.to_s.split(":")
          if validates_content.last
            error_mensages = validates_content.last.to_s.split("|")
            if error_mensages.any?
              error_mensages.each {|err_msg|
                error_mensage = err_msg.split('=')
                if error_mensage.any?
                  error_caption = error_mensage.first
                  error_description = error_mensage.last
                  # adiciona as mensagens de erros para o usuario
                  errors.add(error_caption, error_description)
                end
              }
            end
          end
        end
      end
    end

  end

  private

  def ayty_show_value(value=nil)
    ERB::Util.h(CustomFieldsController.helpers.show_value(value)) if value
  end

  def regex_is_number? string
    if string
      no_commas =  string.gsub(',', '')
      matches = no_commas.match(/-?\d+(?:\.\d+)?/)
      if !matches.nil? && matches.size == 1 && matches[0] == no_commas
        return true
      end
    end
    return false
  end

end

Issue.send :include, AytyIssuePatch