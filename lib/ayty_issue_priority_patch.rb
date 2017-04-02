require_dependency 'issue_priority'

module AytyIssuePriorityPatch
  extend ActiveSupport::Concern
  included do
    class_eval do
    end
  end
  def ayty_get_next_priority
    next_priority = IssuePriority.find_by_position(
      send(:position).to_i + 1
    )
    unless next_priority
      return IssuePriority.where(active: true).sort_by(&:position).last
    end
    next_priority
  end
  class_methods do
    def ayty_get_first_priority
      priority = IssuePriority.where(active: true).sort_by(&:position).first
      return priority if priority
    end
  end
end
IssuePriority.send :include, AytyIssuePriorityPatch
