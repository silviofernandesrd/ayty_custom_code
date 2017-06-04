##### AYTYCRM - Silvio Fernandes #####
require_dependency 'journal'

module AytyJournalPatch
  extend ActiveSupport::Concern

  included do
    class_eval do
      belongs_to :ayty_access_level, :foreign_key => :ayty_access_level_id

      alias_method_chain :save, :ayty_access_level

      alias_method_chain :css_classes, :ayty_custom_css

      alias_method_chain :editable_by?, :ayty_permissions

      alias_method_chain :notified_users, :ayty_filter_notifieds

      alias_method_chain :notified_watchers, :ayty_filter_notifieds

      alias_method_chain :send_notification, :ayty_no_send_mail

      # Adicionado ayty_no_send_mail, para ser utilizado nos metodos que enviam email para nao enviar
      # por enquanto apenas foi adicionado a alteracao feitas nos Journals
      attr_accessor :ayty_no_send_mail

    end
  end

  def send_notification_with_ayty_no_send_mail
    unless ayty_no_send_mail
      if notify? && (Setting.notified_events.include?('issue_updated') ||
          (Setting.notified_events.include?('issue_note_added') && notes.present?) ||
          (Setting.notified_events.include?('issue_status_updated') && new_status.present?) ||
          (Setting.notified_events.include?('issue_assigned_to_updated') && detail_for_attribute('assigned_to_id').present?) ||
          (Setting.notified_events.include?('issue_priority_updated') && new_value_for('priority_id').present?)
      )
        Mailer.deliver_issue_edit(self)
      end
    end
  end

  def notified_users_with_ayty_filter_notifieds
    notified = journalized.notified_users
    if private_notes?
      notified = notified.select {|user| user.allowed_to?(:view_private_notes, journalized.project)}
    end

    # remove usuarios que tenham nivel de acesso menor que o nivel de acesso do comentario
    if ayty_access_level
      notified.reject! {|user| user.ayty_access_level.level < ayty_access_level.level}
    end

    notified
  end

  def notified_watchers_with_ayty_filter_notifieds
    notified = journalized.notified_watchers
    if private_notes?
      notified = notified.select {|user| user.allowed_to?(:view_private_notes, journalized.project)}
    end

    if ayty_access_level
      notified = notified.select {|user| user.ayty_access_level.level >= ayty_access_level.level}
    end

    notified
  end


  # Returns true if the journal can be edited by usr, otherwise false
  def editable_by_with_ayty_permissions?(usr)

    # Acrescentado condicao que caso o tempo apontado for criado nos ultimos 10 minutos permitira qualquer usuario editar o seu proprio apontamento
    if user == usr && created_on >= DateTime.current().ago(600)
      return true
    else

      editable_by_without_ayty_permissions?(usr)

    end
  end


  def css_classes_with_ayty_custom_css
    s = css_classes_without_ayty_custom_css
    if (notes.blank? || !ayty_journal_user_can_view_content?(User.current, ayty_access_level) || ayty_hidden)
      s << ' ayty-journal-blank'
    else
      s << ' ayty-journal-filled'
    end

    s << ' ayty-journal-marked' if ayty_marked?
    s << ' no-overflow-y'
    s
  end

  # Metodo que faz verificação para saber se o usuario possui acesso ao conteudo
  def ayty_journal_user_can_view_content?(user=User.current, ayty_access_level=nil)
    if user && ayty_access_level
      if user.ayty_access_level
        ayty_access_level.level <= user.ayty_access_level.level
      else
        false
      end
    else
      false
    end
  end

  # Metodo que retorna true caso o journal seja da Ayty
  def ayty_is_journal_ayty?
    self.ayty_access_level.ayty_access? if self.ayty_access_level
  end

  # override do metodo salvar para incluir um nivel de acesso caso o mesmo nao seja enviado
  def save_with_ayty_access_level(*args)
    self.ayty_access_level = ayty_access_level_default if self.ayty_access_level_id.nil?
    save_without_ayty_access_level
  end

  # metodo que retorna o nivel de acesso mais baixo caso nenhum valor esteja associado
  def ayty_access_level
    super || AytyAccessLevel.order("level ASC").first
  end

  # metodo que retorna o nivel de acesso mais baixo caso nenhum valor esteja associado
  def ayty_access_level_default
    User.current.ayty_access_level || AytyAccessLevel.order("level ASC").first
  end

  # fitra os detalhes de acordo com as regras de nivel de acesso
  # e se eh ususario ayty ou cliente
  def ayty_filter_details(user=User.current)
    details.select do |detail|
      client_can_view = true

      unless user.ayty_is_user_ayty?
        client_can_view = !['due_date',
                            'assigned_to_bd_id',
                            'assigned_to_net_id',
                            'assigned_to_test_id',
                            'assigned_to_aneg_id',
                            'assigned_to_areq_id',
                            'assigned_to_inf_id',
                            'priority_id',
                            'ayty_manager_priority_user_id',
                            'ayty_manager_priority_date'].include?(detail.prop_key)
      end

      if detail.property == 'cf'
        detail.custom_field &&
          detail.custom_field.visible_by?(project, user) &&
            ayty_user_can_view_content_by_journal?(user, detail.custom_field.ayty_access_level) &&
              client_can_view
      elsif detail.property == 'attachment'
        atta = detail.journal.journalized.attachments.detect {|a| a.id == detail.prop_key.to_i}
        ayty_user_can_view_content_by_journal?(user, (atta.nil? ? self.ayty_access_level : atta.ayty_access_level)) &&
          client_can_view
      elsif detail.property == 'relation'
        Issue.find_by_id(detail.value || detail.old_value).try(:visible?, user) &&
          client_can_view
      else
        true && client_can_view
      end
    end
  end

  private

  # Metodo que faz verificação para saber se o usuario possui acesso ao conteudo
  def ayty_user_can_view_content_by_journal?(user, ayty_access_level)
    if user && ayty_access_level
      if user.ayty_access_level
        ayty_access_level.level <= user.ayty_access_level.level
      else
        false
      end
    else
      false
    end
  end

end

Journal.send :include, AytyJournalPatch
