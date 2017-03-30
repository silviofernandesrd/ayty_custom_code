##### AYTYCRM - Silvio Fernandes #####
require_dependency 'project'

module AytyProjectPatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      alias_method_chain :all_issue_custom_fields, :ayty_custom_rule

      alias_method_chain :shared_versions, :ayty_custom_rule
    end
  end

  def shared_versions_with_ayty_custom_rule
    if new_record?
      Version.
          # acrescentado scopo para filtrar somente abertas
          open.
          joins(:project).
          preload(:project).
          where("#{Project.table_name}.status <> ? AND #{Version.table_name}.sharing = 'system'", Project::STATUS_ARCHIVED)
    else
      @shared_versions ||= begin
        r = root? ? self : root
        Version.
            # acrescentado scopo para filtrar somente abertas
            open.
            joins(:project).
            preload(:project).
            where("#{Project.table_name}.id = #{id}" +
                      " OR (#{Project.table_name}.status <> #{Project::STATUS_ARCHIVED} AND (" +
                      " #{Version.table_name}.sharing = 'system'" +
                      " OR (#{Project.table_name}.lft >= #{r.lft} AND #{Project.table_name}.rgt <= #{r.rgt} AND #{Version.table_name}.sharing = 'tree')" +
                      " OR (#{Project.table_name}.lft < #{lft} AND #{Project.table_name}.rgt > #{rgt} AND #{Version.table_name}.sharing IN ('hierarchy', 'descendants'))" +
                      " OR (#{Project.table_name}.lft > #{lft} AND #{Project.table_name}.rgt < #{rgt} AND #{Version.table_name}.sharing = 'hierarchy')" +
                      "))")
      end
    end
  end

  # Override para traze somente usuario Ayty
  def ayty_assignable_users(ayty_user=false, refresh=false)
    types = ['User']
    types << 'Group' if Setting.issue_group_assignment?

    # pega os roles do usuario
    managed_roles = User.current.ayty_managed_roles(id)

    unless refresh
      @ayty_assignable_ayty_users ||= ayty_find_assignable_ayty_users(id, types, ayty_user, managed_roles)
    else
      @ayty_assignable_ayty_users = ayty_find_assignable_ayty_users(id, types, ayty_user, managed_roles)
    end
  end

  def ayty_find_assignable_ayty_users(project_id, types, ayty_user, managed_roles)
    Principal.
        active.
        # acrescentado join com a ayty_access_level para validar se o usuario eh Ayty
        ayty_filter_access_levels(:ayty_user => ayty_user).
        # feito join com a MemberRole e depois com a AytyManagedRole para filtrar somente os papeis
        # que o usuario logado pode ver
        ayty_filter_managed_roles(:managed_roles => managed_roles).
        joins(:members => :roles).
        where(:type => types,
              :members => {:project_id => project_id},
              :roles => {:assignable => true}).
        uniq.
        sorted
  end

  # override
  # Returns a scope of all custom fields enabled for project issues
  # (explicitly associated custom fields and custom fields enabled for all projects)
  def all_issue_custom_fields_with_ayty_custom_rule
    if new_record?
      @all_issue_custom_fields ||= IssueCustomField.
          sorted.
          where("is_for_all = ? OR #{IssueCustomField.table_name}.id IN (?)", true, issue_custom_field_ids)
    else
      @all_issue_custom_fields ||= IssueCustomField.
          sorted.
          where("is_for_all = ? OR #{IssueCustomField.table_name}.id IN (SELECT DISTINCT cfp.custom_field_id" +
                    " FROM #{table_name_prefix}custom_fields_projects#{table_name_suffix} cfp" +
                    " WHERE cfp.project_id = ?)", true, id)
    end
  end
end

Project.send :include, AytyProjectPatch
