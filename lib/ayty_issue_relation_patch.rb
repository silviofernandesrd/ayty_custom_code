##### AYTYCRM - Silvio Fernandes #####
require_dependency 'issue_relation'

module AytyIssueRelationPatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      # remover esta customizacao quando migrar para versao 3.3.0
      # FIX: https://www.redmine.org/issues/13654
      alias_method_chain :validate_issue_relation, :ayty_fix_parent_associations

    end
  end

  #override
  # remover esta customizacao quando migrar para versao 3.3.0
  # FIX: https://www.redmine.org/issues/13654
  def validate_issue_relation_with_ayty_fix_parent_associations
    if issue_from && issue_to
      errors.add :issue_to_id, :invalid if issue_from_id == issue_to_id
      unless issue_from.project_id == issue_to.project_id ||
          Setting.cross_project_issue_relations?
        errors.add :issue_to_id, :not_same_project
      end
      # remover esta customizacao quando migrar para versao 3.3.0
      # FIX: https://www.redmine.org/issues/13654
      # detect circular dependencies depending wether the relation should be reversed
      #if TYPES.has_key?(relation_type) && TYPES[relation_type][:reverse]
      #  errors.add :base, :circular_dependency if issue_from.all_dependent_issues.include? issue_to
      #else
      #  errors.add :base, :circular_dependency if issue_to.all_dependent_issues.include? issue_from
      if circular_dependency?
        errors.add :base, :circular_dependency
      end
      if issue_from.is_descendant_of?(issue_to) || issue_from.is_ancestor_of?(issue_to)
        errors.add :base, :cant_link_an_issue_with_a_descendant
      end
    end
  end

  # remover esta customizacao quando migrar para versao 3.3.0
  # FIX: https://www.redmine.org/issues/13654
  # Returns true if the relation would create a circular dependency
  def circular_dependency?
    case relation_type
    when 'follows'
      issue_from.would_reschedule? issue_to
    when 'precedes'
      issue_to.would_reschedule? issue_from
    when 'blocked'
      issue_from.blocks? issue_to
    when 'blocks'
      issue_to.blocks? issue_from
  else
    false
  end
end

end

IssueRelation.send :include, AytyIssueRelationPatch