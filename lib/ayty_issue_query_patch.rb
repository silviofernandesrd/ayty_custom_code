##### AYTYCRM - Silvio Fernandes #####
require_dependency 'issue_query'

module AytyIssueQueryPatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      alias_method_chain :initialize_available_filters, :ayty_custom_columns
      alias_method_chain :available_columns, :ayty_available_columns
      alias_method_chain :issues, :ayty_fix_problem_order_by

    end
  end

  # override para resolver problema com ORDER BY com colunas duplicadas no SQL Server
  # Returns the issues
  # Valid options are :order, :offset, :limit, :include, :conditions
  def issues_with_ayty_fix_problem_order_by(options={})
    if group_by_sort_order.is_a?(String)
      # caso a variavel group_by_sort_order seja uma String, converte a mesma para Array
      # para funcionar um distinct depois nas colunas
      order_option = [group_by_sort_order.split(','), options[:order]].flatten.reject(&:blank?)
    else
      order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)
    end

    scope = Issue.visible.
        joins(:status, :project).
        where(statement).
        includes(([:status, :project] + (options[:include] || [])).uniq).
        where(options[:conditions]).
        order(order_option).
        joins(joins_for_order_statement(order_option.join(','))).
        limit(options[:limit]).
        offset(options[:offset])

    scope = scope.preload(:custom_values)
    if has_column?(:author)
      scope = scope.preload(:author)
    end

    issues = scope.to_a

    if has_column?(:spent_hours)
      Issue.load_visible_spent_hours(issues)
    end
    if has_column?(:total_spent_hours)
      Issue.load_visible_total_spent_hours(issues)
    end
    if has_column?(:relations)
      Issue.load_visible_relations(issues)
    end
    issues
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  # Override para incluir responsaveis como filtro
  def available_columns_with_ayty_available_columns

    return @available_columns if @available_columns
    @available_columns = self.class.available_columns.dup
    @available_columns += (project ?
        project.all_issue_custom_fields :
        IssueCustomField
    ).ayty_filter_access_level(User.current).visible.collect {|cf| QueryCustomFieldColumn.new(cf) }

    if User.current.allowed_to?(:view_time_entries, project, :global => true)
      index = @available_columns.find_index {|column| column.name == :total_estimated_hours}
      index = (index ? index + 1 : -1)
      # insert the column after total_estimated_hours or at the end
      @available_columns.insert index, QueryColumn.new(:spent_hours,
                                                       :sortable => "COALESCE((SELECT SUM(hours) FROM #{TimeEntry.table_name} WHERE #{TimeEntry.table_name}.issue_id = #{Issue.table_name}.id), 0)",
                                                       :default_order => 'desc',
                                                       :caption => :label_spent_time
      )
      @available_columns.insert index+1, QueryColumn.new(:total_spent_hours,
                                                         :sortable => "COALESCE((SELECT SUM(hours) FROM #{TimeEntry.table_name} JOIN #{Issue.table_name} subtasks ON subtasks.id = #{TimeEntry.table_name}.issue_id" +
                                                             " WHERE subtasks.root_id = #{Issue.table_name}.root_id AND subtasks.lft >= #{Issue.table_name}.lft AND subtasks.rgt <= #{Issue.table_name}.rgt), 0)",
                                                         :default_order => 'desc',
                                                         :caption => :label_total_spent_time
      )
    end

    if User.current.allowed_to?(:set_issues_private, nil, :global => true) ||
        User.current.allowed_to?(:set_own_issues_private, nil, :global => true)
      @available_columns << QueryColumn.new(:is_private, :sortable => "#{Issue.table_name}.is_private")
    end

    disabled_fields = Tracker.disabled_core_fields(trackers).map {|field| field.sub(/_id$/, '')}
    @available_columns.reject! {|column|
      disabled_fields.include?(column.name.to_s)
    }

    #remove os campos que o usuario nao tem acesso

    # caso o usuario nao seja ayty remove prioridade e data prevista
    unless User.current.ayty_is_user_ayty?
      @available_columns.reject! {|column|
        ['due_date','priority'].include?(column.name.to_s)
      }
    end

    # adicionar colunas de responsaveis
    @available_columns << QueryColumn.new(:assigned_to_net)
    @available_columns << QueryColumn.new(:assigned_to_bd)
    @available_columns << QueryColumn.new(:assigned_to_test)
    @available_columns << QueryColumn.new(:assigned_to_aneg)
    @available_columns << QueryColumn.new(:assigned_to_areq)
    @available_columns << QueryColumn.new(:assigned_to_inf)

    @available_columns
  end

  # Override para incluir responsaveis como filtro
  def initialize_available_filters_with_ayty_custom_columns

    principals = []
    subprojects = []
    versions = []
    categories = []
    issue_custom_fields = []

    if project
      principals += project.principals.visible
      unless project.leaf?
        subprojects = project.descendants.visible.to_a
        principals += Principal.member_of(subprojects).visible
      end
      versions = project.shared_versions.to_a
      categories = project.issue_categories.to_a
      issue_custom_fields = project.all_issue_custom_fields
    else
      if all_projects.any?
        principals += Principal.member_of(all_projects).visible
      end
      versions = Version.visible.where(:sharing => 'system').to_a
      issue_custom_fields = IssueCustomField.where(:is_for_all => true)
    end
    principals.uniq!
    principals.sort!
    principals.reject! {|p| p.is_a?(GroupBuiltin)}
    users = principals.select {|p| p.is_a?(User)}

    add_available_filter "status_id",
                         :type => :list_status, :values => IssueStatus.sorted.collect{|s| [s.name, s.id.to_s] }

    if project.nil?
      project_values = []
      if User.current.logged? && User.current.memberships.any?
        project_values << ["<< #{l(:label_my_projects).downcase} >>", "mine"]
      end
      project_values += all_projects_values
      add_available_filter("project_id",
                           :type => :list, :values => project_values
      ) unless project_values.empty?
    end

    add_available_filter "tracker_id",
                         :type => :list, :values => trackers.collect{|s| [s.name, s.id.to_s] }
    add_available_filter "priority_id",
                         :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }

    author_values = []
    author_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    author_values += users.collect{|s| [s.name, s.id.to_s] }
    add_available_filter("author_id",
                         :type => :list, :values => author_values
    ) unless author_values.empty?

    assigned_to_values = []
    assigned_to_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    assigned_to_values += (Setting.issue_group_assignment? ?
        principals : users).collect{|s| [s.name, s.id.to_s] }
    add_available_filter("assigned_to_id",
                         :type => :list_optional, :values => assigned_to_values
    ) unless assigned_to_values.empty?

    group_values = Group.givable.visible.collect {|g| [g.name, g.id.to_s] }
    add_available_filter("member_of_group",
                         :type => :list_optional, :values => group_values
    ) unless group_values.empty?

    role_values = Role.givable.collect {|r| [r.name, r.id.to_s] }
    add_available_filter("assigned_to_role",
                         :type => :list_optional, :values => role_values
    ) unless role_values.empty?

    add_available_filter "fixed_version_id",
                         :type => :list_optional,
                         :values => versions.sort.collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s] }

    add_available_filter "category_id",
                         :type => :list_optional,
                         :values => categories.collect{|s| [s.name, s.id.to_s] }

    add_available_filter "subject", :type => :text
    add_available_filter "description", :type => :text
    add_available_filter "created_on", :type => :date_past
    add_available_filter "updated_on", :type => :date_past
    add_available_filter "closed_on", :type => :date_past
    add_available_filter "start_date", :type => :date
    add_available_filter "due_date", :type => :date
    add_available_filter "estimated_hours", :type => :float
    add_available_filter "done_ratio", :type => :integer

    if User.current.allowed_to?(:set_issues_private, nil, :global => true) ||
        User.current.allowed_to?(:set_own_issues_private, nil, :global => true)
      add_available_filter "is_private",
                           :type => :list,
                           :values => [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]]
    end

    if User.current.logged?
      add_available_filter "watcher_id",
                           :type => :list, :values => [["<< #{l(:label_me)} >>", "me"]]
    end

    if subprojects.any?
      add_available_filter "subproject_id",
                           :type => :list_subprojects,
                           :values => subprojects.collect{|s| [s.name, s.id.to_s] }
    end

    add_custom_fields_filters(issue_custom_fields.ayty_filter_access_level(User.current))

    add_associations_custom_fields_filters :project, :author, :assigned_to, :fixed_version

    IssueRelation::TYPES.each do |relation_type, options|
      add_available_filter relation_type, :type => :relation, :label => options[:name]
    end
    add_available_filter "parent_id", :type => :tree, :label => :field_parent_issue
    add_available_filter "child_id", :type => :tree, :label => :label_subtask_plural

    Tracker.disabled_core_fields(trackers).each {|field|
      delete_available_filter field
    }

    # deleta filtros
    delete_available_filter "priority_id"
    delete_available_filter "due_date"
    delete_available_filter "fixed_version_id"

    versions_open = []

    if project
      versions_open = project.shared_versions.to_a
    else
      #versions = Version.visible.where(:sharing => 'system').to_a
      versions_open = Version.open.visible.where(:sharing => 'system').to_a
    end

    # caso o usuario nao seja ayty remove prioridade
    #add_available_filter "priority_id",
    #                     :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }
    add_available_filter "priority_id",
                         :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] } if User.current.ayty_is_user_ayty?

    # caso o usuario nao seja ayty remove data prevista
    #add_available_filter "due_date", :type => :date
    add_available_filter "due_date", :type => :date if User.current.ayty_is_user_ayty?

    if versions_open.any?
      add_available_filter "fixed_version_id",
                           :type => :list_optional,
                           :values => versions_open.sort.collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s] }
    end

    # pega somente usuarios ayty
    ayty_users = []
    ayty_users << ["<< #{l(:label_me)} >>", User.current.id] if User.current.logged?
    # projeto especifico
    if project
      ayty_users += project.ayty_assignable_users(true).collect{|s| [s.name, s.id.to_s] }
    else
      # todos projetos
      if all_projects.any?
        ayty_users += Principal.joins(:ayty_access_level).where(:ayty_access_levels => {:ayty_access => true}).member_of(all_projects).visible.collect{|s| [s.name, s.id.to_s] }
      end
    end
    ayty_users.uniq!
    ayty_users.sort!

    # inclui filtros
    add_available_filter("assigned_to_bd_id",
                         :type => :list_optional, :values => ayty_users
    ) unless ayty_users.empty?

    add_available_filter("assigned_to_net_id",
                         :type => :list_optional, :values => ayty_users
    ) unless ayty_users.empty?

    add_available_filter("assigned_to_test_id",
                         :type => :list_optional, :values => ayty_users
    ) unless ayty_users.empty?

    add_available_filter("assigned_to_aneg_id",
                         :type => :list_optional, :values => ayty_users
    ) unless ayty_users.empty?

    add_available_filter("assigned_to_areq_id",
                         :type => :list_optional, :values => ayty_users
    ) unless ayty_users.empty?

    add_available_filter("assigned_to_inf_id",
                         :type => :list_optional, :values => ayty_users
    ) unless ayty_users.empty?

  end
end

IssueQuery.send :include, AytyIssueQueryPatch
