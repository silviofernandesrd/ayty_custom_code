##### AYTYCRM - Silvio Fernandes #####
require_dependency 'time_entry'

module AytyTimeEntryPatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      belongs_to :ayty_time_entry_type

      validates_presence_of :ayty_time_entry_type_id, :comments

      safe_attributes 'ayty_time_entry_type_id'

      alias_method_chain :editable_by?, :ayty_permissions

      # Proibir apontamento de X dias pra trás. Liberar por pessoa basta usar 0
      validate :block_retroactive_time_entry
      # Travar mais de X horas de apontamento no mesmo dia
      validate :maximum_time_entry_per_day

    end
  end

  # Returns true if the time entry can be edited by usr, otherwise false
  def editable_by_with_ayty_permissions?(usr)

    # Acrescentado condicao que caso o tempo apontado for criado nos ultimos 10 minutos permitira qualquer usuario editar o seu proprio apontamento
    if user == usr && created_on >= DateTime.current().ago(600)
      return true
    else

      editable_by_without_ayty_permissions?(usr)

    end

  end

  # Proibir apontamento de X dias pra trás. Liberar por pessoa basta usar 0
  def block_retroactive_time_entry
    days_to_block = User.current.days_to_block_retroactive_time_entry
    unless days_to_block.nil?
      if days_to_block.to_i > 0
        if (Date.today - spent_on.to_date).to_i > days_to_block.to_i
          errors.add(:block_retroactive_time_entry, "#{User.current.days_to_block_retroactive_time_entry} #{l(:label_day_plural)}")
        end
      end
    end
  end

  # Travar mais de X horas de apontamento no mesmo dia
  # Passado tambem o id do time_entry para metodo que valida quantidade de horas
  def maximum_time_entry_per_day
    hours_to_block = User.current.maximum_hours_allowed_to_time_entry_per_day
    if hours_to_block.to_i > 0
      ayty_hours = get_hours_spent_on_day_by_user(User.current, spent_on.to_date, id)
      if ayty_hours
        hours_to_validate = ayty_hours.to_f + hours.to_f
        if hours_to_validate > hours_to_block.to_f
          errors.add(:maximum_time_entry_per_day, l(:label_hours_in_same_day, :hours => hours_to_block))
        end
      end
    end
  end

  # Travar mais de X horas de apontamento no mesmo dia
  # Retorna a quantidade de horas apontadas por um usuario num determinado dia
  # Alterado metodo para receber tambem o id do time_entry e exclui-lo na soma
  # porque quando e editado um valor ele conta novamente para o calculo de restricao
  def get_hours_spent_on_day_by_user(user, date, exclude_time_entry_id=nil)
    if user and date
      conditions = "#{TimeEntry.table_name}.user_id = #{user.id} and #{TimeEntry.table_name}.spent_on = '#{date}'"
      conditions += " and #{TimeEntry.table_name}.id <> #{exclude_time_entry_id}" if exclude_time_entry_id
      hours = TimeEntry.where(conditions).all.map(&:hours).sum
      hours if hours
    end
  end

end

TimeEntry.send :include, AytyTimeEntryPatch
