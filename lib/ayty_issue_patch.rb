require_dependency 'issue'
module AytyIssuePatch
  extend ActiveSupport::Concern
  included do
    class_eval do
      include Ayty::AytyManagement

      belongs_to :assigned_to_bd, class_name: 'User', foreign_key: 'assigned_to_bd_id'
      belongs_to :assigned_to_net, class_name: 'User', foreign_key: 'assigned_to_net_id'
      belongs_to :assigned_to_test, class_name: 'User', foreign_key: 'assigned_to_test_id'
      belongs_to :assigned_to_aneg, class_name: 'User', foreign_key: 'assigned_to_aneg_id'
      belongs_to :assigned_to_areq, class_name: 'User', foreign_key: 'assigned_to_areq_id'
      belongs_to :assigned_to_inf, class_name: 'User', foreign_key: 'assigned_to_inf_id'
      belongs_to :ayty_manager_priority_user, class_name: 'User', foreign_key: 'ayty_manager_priority_user_id'
      has_many :time_trackers, foreign_key: :issue_id

      delegate :ayty_access_level_id, :ayty_access_level_id=, to: :current_journal, allow_nil: true

      safe_attributes 'ayty_access_level_id',
                      'assigned_to_bd_id',
                      'assigned_to_net_id',
                      'assigned_to_test_id',
                      'assigned_to_aneg_id',
                      'assigned_to_areq_id',
                      'assigned_to_inf_id',
                      'ayty_manager_priority_user_id',
                      'ayty_manager_priority_date',
                      'development_date'

      scope :ayty_issues_priority, lambda { |user|
        joins(:priority).where(assigned_to_id: user).order("#{IssuePriority.table_name}.position")
      }

      scope :ayty_issues_responsible_open, lambda { |user|
        where("(#{Issue.table_name}.assigned_to_bd_id = :u
         or #{Issue.table_name}.assigned_to_net_id = :u
         or #{Issue.table_name}.assigned_to_test_id = :u
         or #{Issue.table_name}.assigned_to_aneg_id = :u
         or #{Issue.table_name}.assigned_to_areq_id = :u
         or #{Issue.table_name}.assigned_to_inf_id = :u)
         and (
         (#{Issue.table_name}.status_id in (14,25) and
         #{Issue.table_name}.updated_on > :date)
         or #{Issue.table_name}.status_id not in (14,25))
         and #{Issue.table_name}.assigned_to_id <> :u", u: user, date: 1.month.ago)
          .order("CASE #{Issue.table_name}.status_id
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
          ELSE 12 END")
      }

      scope :ayty_issues_responsible_closed, lambda { |user|
        joins(:status)
          .where("(#{Issue.table_name}.assigned_to_bd_id = :u
            or #{Issue.table_name}.assigned_to_net_id = :u
            or #{Issue.table_name}.assigned_to_test_id = :u
            or #{Issue.table_name}.assigned_to_aneg_id = :u
            or #{Issue.table_name}.assigned_to_areq_id = :u
            or #{Issue.table_name}.assigned_to_inf_id = :u)
            and #{Issue.table_name}.updated_on > :date
            and #{IssueStatus.table_name}.is_closed = :c", u: user, date: 3.days.ago, c: true)
          .order("#{Issue.table_name}.id")
      }

      scope :ayty_issues_watcher, lambda { |user|
        joins(:watchers).where("#{Watcher.table_name}.watchable_type = 'Issue' and #{Watcher.table_name}.user_id = :u", u: user)
      }

      scope :ayty_issues_time_tracker_pendings, lambda { |user|
        joins(:time_trackers).where("#{TimeTracker.table_name}.user_id = :u", u: user)
      }

      scope :ayty_exclude_issues_id, lambda { |issues_id|
        where("#{Issue.table_name}.id not in (#{issues_id})")
      }

      before_save :ayty_priority
      after_update :ayty_call_procedure_after_save
      attr_accessor :ayty_before_time_entry
      alias_method_chain :init_journal, :ayty_before_changes
      alias_method_chain :notified_users, :ayty_filter_notifieds
      alias_method_chain :editable_custom_field_values, :ayty_custom_rule
      alias_method_chain :visible_custom_field_values, :ayty_custom_rule
      alias_method_chain :copy_from, :clean_fields
      validate :ayty_call_procedure_before_save
      _validators.delete(:priority)
      _validate_callbacks.each do |callback|
        if callback.raw_filter.respond_to? :attributes
          callback.raw_filter.attributes.delete :priority
        end
      end
    end
  end

  def copy_from_with_clean_fields(arg, options = {})
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

      issue.custom_field_values.reject! { |cfv| cfv.custom_field.clear_value_to_copy? }

      copy_from_without_clean_fields(issue, options)
    end

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
  def init_journal_with_ayty_before_changes(user, notes = '')
    @ayty_custom_values_before_change = custom_field_values
                                        .each_with_object({}) do |custom, hash|
      hash[custom.custom_field_id] = custom.value
      hash
    end
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

  def ayty_priority
    if assigned_to && status
      if assigned_to.ayty_is_user_ayty? && !status.is_closed &&
         assigned_to_id_changed?
        assigned_to_issues = Issue.visible.open.joins(:priority)
                                  .where(assigned_to_id: assigned_to)
                                  .order("#{IssuePriority.table_name}.position")
        if assigned_to_issues.count > 0
          self.priority = assigned_to_issues.last.priority
                                            .ayty_get_next_priority
        end
      end
    end
    self.priority = IssuePriority.ayty_get_first_priority unless priority
  end

  def ayty_get_value_by_custom_field_name(custom_field_name, default_value = '')
    custom_value_detected = custom_field_values.detect do |value|
      value.custom_field.name == custom_field_name
    end
    return ayty_show_value(custom_value_detected) if custom_value_detected
    default_value
  end

  # Metodo utilizado para recuperar a Data da ultima atualizacao de um campo customizavel
  def ayty_get_last_modification_by_custom_field_name(custom_field_name)
    journals_finded = journals.find_all do |journal|
      journal if journal.details.detect do |detail|
        detail.custom_field.name == custom_field_name if detail.custom_field
      end
    end
    return nil unless journals_finded.any?
    ayty_show_value(journals_finded.last.created_on)
  end

  # Replicado metodo para retornar as horas gastas de um determinado usuario no ticket em questao
  def ayty_spent_hours_by_user (user)
    @ayty_spent_hours_by_user ||= begin
      time_entries.where(user: user).sum(:hours) || 0
    end

  end
  def ayty_call_procedure_after_save
    assigned_to_id_changed = changes['assigned_to_id']
    status_id_changed = changes['status_id']
    if assigned_to_id_changed || status_id_changed
      assigned_to_id_new_parsed = 'null'
      assigned_to_id_old_parsed = 'null'
      assigned_to_ayty_role_id_new_parsed = 'null'
      assigned_to_ayty_role_id_old_parsed = 'null'
      status_id_new_parsed = 'null'
      status_id_old_parsed = 'null'
      if assigned_to_id_changed
        if assigned_to_id_changed.any?
          assigned_to_id_new_parsed = assigned_to_id_changed.last
          assigned_to_ayty_role_id_new_parsed = 'null'
          if assigned_to
            if assigned_to.ayty_role_id
              assigned_to_ayty_role_id_new_parsed = assigned_to.ayty_role_id
            end
          end
          if assigned_to_id_changed.first
            assigned_to_id_old_parsed = assigned_to_id_changed.first
          end
          if assigned_to_id_old_parsed && assigned_to_id_old_parsed != 'null'
            assigned_to_ayty_role_id_old_parsed = 'null'
            user_old = User.find(assigned_to_id_old_parsed)
            if user_old && user_old.ayty_role_id
              assigned_to_ayty_role_id_old_parsed = user_old.ayty_role_id
            end
          end
        end
      end
      if status_id_changed
        if status_id_changed.any?
          status_id_new_parsed = status_id_changed.last
          if status_id_changed.first
            status_id_old_parsed = status_id_changed.first
          end
        end
      end
      issue_id_parsed = id.nil? ? 'null' : id
      assigned_to_inf_id_parsed = assigned_to_inf_id.nil? ? 'null' : assigned_to_inf_id
      user_current_parsed = User.current.nil? ? 'null' : User.current.id
      user_current_ayty_role_id_parsed = User.current.ayty_role_id.nil? ? 'null' : User.current.ayty_role_id
      cf_status_post_delivery = ayty_get_value_by_custom_field_name('Status pós-Entrega', '')
      sql = case ActiveRecord::Base.connection_config[:adapter]
            when 'postgresql'
              "
              select spr_ayty_validate_update_issue_after(
                issue_id := #{issue_id_parsed},
                assigned_to_id_old := #{assigned_to_id_old_parsed},
                assigned_to_ayty_role_id_old := #{assigned_to_ayty_role_id_old_parsed},
                assigned_to_id := #{assigned_to_id_new_parsed},
                assigned_to_ayty_role_id := #{assigned_to_ayty_role_id_new_parsed},
                status_id_old := #{status_id_old_parsed},
                status_id := #{status_id_new_parsed},
                assigned_to_inf_id := #{assigned_to_inf_id_parsed},
                cf_status_post_delivery := '#{cf_status_post_delivery}',
                current_user_id := #{user_current_parsed},
                current_user_ayty_role_id := #{user_current_ayty_role_id_parsed}
              )
              "
            when 'sqlserver'
              "
              exec spr_ayty_validate_update_issue_after
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
                @current_user_ayty_role_id = #{user_current_ayty_role_id_parsed}
              "
            end
      # executa procedure
      ActiveRecord::Base.connection.exec_query(sql)
    end
  end

  def ayty_call_procedure_before_save

    issue_id_parsed = id.nil? ? 'null' : id

    assigned_to_id_valid = assigned_to_id.nil? ? 'null' : assigned_to_id
    assigned_to_id_parsed = assigned_to_id_valid
    assigned_to_id_old_parsed = assigned_to_id_was.nil? ? 'null' : assigned_to_id_was

    assigned_to_ayty_role_id_parsed = 'null'
    assigned_to_ayty_role_id_parsed = assigned_to.ayty_role_id.nil? ? 'null' : assigned_to.ayty_role_id if assigned_to

    assigned_to_ayty_role_id_old_parsed = 'null'
    if assigned_to_id_old_parsed != 'null'
      if user_old = User.find(assigned_to_id_old_parsed)
        assigned_to_ayty_role_id_old_parsed = user_old.ayty_role_id.nil? ? 'null' : user_old.ayty_role_id
      end
    end

    status_id_valid = status_id.nil? ? 'null' : status_id
    status_id_parsed = status_id_valid
    status_id_old_parsed = status_id_was.nil? ? 'null' : status_id_was

    assigned_to_bd_id_parsed = assigned_to_bd_id.nil? ? 'null' : assigned_to_bd_id
    assigned_to_net_id_parsed = assigned_to_net_id.nil? ? 'null' : assigned_to_net_id
    assigned_to_test_id_parsed = assigned_to_test_id.nil? ? 'null' : assigned_to_test_id
    assigned_to_areq_id_parsed = assigned_to_areq_id.nil? ? 'null' : assigned_to_areq_id
    assigned_to_aneg_id_parsed = assigned_to_aneg_id.nil? ? 'null' : assigned_to_aneg_id
    assigned_to_inf_id_parsed = assigned_to_inf_id.nil? ? 'null' : assigned_to_inf_id
    fixed_version_id_parsed = fixed_version_id.nil? ? 'null' : fixed_version_id
    due_date_parsed = due_date.nil? ? '' : due_date

    if @current_journal
      notes_parsed = @current_journal.notes.nil? ? '' : @current_journal.notes.gsub("'", "\\\'")
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
      cf_estimation_bd_old = @ayty_custom_values_before_change[29].nil? ? '' : @ayty_custom_values_before_change[29]
      cf_estimation_sys_old = @ayty_custom_values_before_change[30].nil? ? '' : @ayty_custom_values_before_change[30]
      cf_estimation_sys_col_old = @ayty_custom_values_before_change[54].nil? ? '' : @ayty_custom_values_before_change[54]
      cf_estimation_inf_old = @ayty_custom_values_before_change[34].nil? ? '' : @ayty_custom_values_before_change[34]
      cf_remainder_time_bd_old = @ayty_custom_values_before_change[58].nil? ? '' : @ayty_custom_values_before_change[58]
      cf_remainder_time_sys_old = @ayty_custom_values_before_change[59].nil? ? '' : @ayty_custom_values_before_change[59]
      cf_remainder_time_sys_col_old = @ayty_custom_values_before_change[61].nil? ? '' : @ayty_custom_values_before_change[61]
      cf_remainder_time_inf_old = @ayty_custom_values_before_change[65].nil? ? '' : @ayty_custom_values_before_change[65]
    end


    cf_request_type = ayty_get_value_by_custom_field_name('Tipo de Solicitação', '')
    cf_solution_type = ayty_get_value_by_custom_field_name('Tipo de Solução', '')
    cf_estimation_bd = ayty_get_value_by_custom_field_name('Estimativa BD - hr', '')
    cf_estimation_sys = ayty_get_value_by_custom_field_name('Estimativa SIS - hr', '')
    cf_estimation_sys_col = ayty_get_value_by_custom_field_name('Estimativa SIS Colab - hr', '')
    cf_estimation_inf = ayty_get_value_by_custom_field_name('Estimativa Infra - hr', '')
    cf_remainder_time_bd  = ayty_get_value_by_custom_field_name('Tempo Restante BD', '')
    cf_remainder_time_sys = ayty_get_value_by_custom_field_name('Tempo Restante SIS', '')
    cf_remainder_time_sys_col = ayty_get_value_by_custom_field_name('Tempo Restante SIS Colab', '')
    cf_remainder_time_inf = ayty_get_value_by_custom_field_name('Tempo Restante Infra', '')
    cf_quality_ticket_to_reach_areq = ayty_get_value_by_custom_field_name('Quality Tkt ao chegar pro AREQ', '')
    cf_quality_ticket_to_reach_des = ayty_get_value_by_custom_field_name('Quality Tkt ao chegar pra DES', '')
    cf_release_general_internal = ayty_get_value_by_custom_field_name('Release Geral - Interno', '')
    cf_release_col_internal = ayty_get_value_by_custom_field_name('Release Colab - Interno', '')
    cf_status_post_delivery = ayty_get_value_by_custom_field_name('Status pós-Entrega', '')
    cf_instructions_to_deploy = ayty_get_value_by_custom_field_name('Instruções para Deploy', '')
    cf_law_of_good = ayty_get_value_by_custom_field_name('Lei do Bem', '')

    time_entry_hours = ayty_before_time_entry.nil? ? '' : ayty_before_time_entry.hours
    time_entry_spent_on = ayty_before_time_entry.nil? ? '' : ayty_before_time_entry.spent_on
    time_entry_comments = ayty_before_time_entry.nil? ? '' : ayty_before_time_entry.comments
    time_entry_activity_id = ayty_before_time_entry.nil? ? 'null' : ayty_before_time_entry.activity_id
    #time_entry_time_entry_type_id = ayty_before_time_entry.time_entry_type_id.nil? ? 'null' : ayty_before_time_entry.time_entry_type_id
    time_entry_time_entry_type_id = 'null' # falta implementar codigo

    sql = case ActiveRecord::Base.connection_config[:adapter]
          when 'postgresql'
            "
            select * from spr_ayty_validate_update_issue_before(
              issue_id := #{issue_id_parsed},
              assigned_to_id_old := #{assigned_to_id_old_parsed},
              assigned_to_ayty_role_id_old := #{assigned_to_ayty_role_id_old_parsed},
              assigned_to_id := #{assigned_to_id_parsed},
              assigned_to_ayty_role_id := #{assigned_to_ayty_role_id_parsed},
              status_id_old := #{status_id_old_parsed},
              status_id := #{status_id_parsed},
              assigned_to_bd_id := #{assigned_to_bd_id_parsed},
              assigned_to_net_id := #{assigned_to_net_id_parsed},
              assigned_to_test_id := #{assigned_to_test_id_parsed},
              assigned_to_areq_id := #{assigned_to_areq_id_parsed},
              assigned_to_aneg_id := #{assigned_to_aneg_id_parsed},
              assigned_to_inf_id := #{assigned_to_inf_id_parsed},
              fixed_version_id := #{fixed_version_id_parsed},
              due_date := '#{due_date_parsed}',
              cf_request_type := '#{cf_request_type}',
              cf_solution_type := '#{cf_solution_type}',
              cf_estimation_bd_old := '#{cf_estimation_bd_old}',
              cf_estimation_bd := '#{cf_estimation_bd}',
              cf_estimation_sys_old := '#{cf_estimation_sys_old}',
              cf_estimation_sys := '#{cf_estimation_sys}',
              cf_estimation_sys_col_old := '#{cf_estimation_sys_col_old}',
              cf_estimation_sys_col := '#{cf_estimation_sys_col}',
              cf_estimation_inf_old := '#{cf_estimation_inf_old}',
              cf_estimation_inf := '#{cf_estimation_inf}',
              cf_remainder_time_bd_old := '#{cf_remainder_time_bd_old}',
              cf_remainder_time_bd := '#{cf_remainder_time_bd}',
              cf_remainder_time_sys_old := '#{cf_remainder_time_sys_old}',
              cf_remainder_time_sys := '#{cf_remainder_time_sys}',
              cf_remainder_time_sys_col_old := '#{cf_remainder_time_sys_col_old}',
              cf_remainder_time_sys_col := '#{cf_remainder_time_sys_col}',
              cf_remainder_time_inf_old := '#{cf_remainder_time_inf_old}',
              cf_remainder_time_inf := '#{cf_remainder_time_inf}',
              cf_quality_ticket_to_reach_areq := '#{cf_quality_ticket_to_reach_areq}',
              cf_quality_ticket_to_reach_des := '#{cf_quality_ticket_to_reach_des}',
              cf_release_general_internal := '#{cf_release_general_internal}',
              cf_release_col_internal := '#{cf_release_col_internal}',
              cf_status_post_delivery := '#{cf_status_post_delivery}',
              cf_instructions_to_deploy := '#{cf_instructions_to_deploy}',
              notes := '#{notes_parsed}',
              current_user_id := #{user_current_parsed},
              current_user_ayty_role_id := #{user_current_ayty_role_id_parsed},
              time_entry_hours := '#{time_entry_hours}',
              time_entry_spent_on := '#{time_entry_spent_on}',
              time_entry_comments := '#{time_entry_comments}',
              time_entry_activity_id := #{time_entry_activity_id},
              time_entry_time_entry_type_id := #{time_entry_time_entry_type_id},
              cf_law_of_good := '#{cf_law_of_good}'
            )
            "
          when 'sqlserver'
            "
            exec spr_ayty_validate_update_issue_before
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
              @time_entry_time_entry_type_id = #{time_entry_time_entry_type_id},
              @cf_law_of_good = '#{cf_law_of_good}'
            "
          end

    # executa a procedure e pega o resultado
    result = ActiveRecord::Base.connection.exec_query(sql)

    # valida retorno
    if result
      validates = result.first['validates']
      if validates
        # se o retorno for diferente de OK
        # prepara o resultado recebido para exibir para o usuario
        unless validates == 'OK'
          validates_content = validates.to_s.split(':')
          if validates_content.last
            error_mensages = validates_content.last.to_s.split('|')
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
