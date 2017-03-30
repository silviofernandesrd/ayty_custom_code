##### AYTYCRM - Silvio Fernandes #####
require_dependency 'issue_priority'

module AytyIssuePriorityPatch
  extend ActiveSupport::Concern

  included do
    class_eval do
    end
  end

  # metodo para retornar a proxima prioridade
  # caso nao exista proxima pega ultima disponivel
  def ayty_get_next_priority
    next_priority = IssuePriority.find_by_position(self.send(position_column).to_i + 1)
    if next_priority.nil?
      next_priority = IssuePriority.where(:active => true).sort_by(&:position).last
    end
    next_priority
  end


  class_methods do

    # metodo para retornar a primeira prioridade disponivel
    def ayty_get_first_priority
      priority = IssuePriority.where(:active => true).sort_by(&:position).first
      priority unless priority.nil?
    end

  end

end

IssuePriority.send :include, AytyIssuePriorityPatch