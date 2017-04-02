require 'redmine'

require 'ayty_field_format_patch'
ActiveRecord::Base.send(:include, Redmine::FieldFormat)
require 'ayty_acts_as_watchable_patch'
ActiveRecord::Base.send(:include, Redmine::Acts::Watchable)
# require 'ayty_acts_as_customizable_patch'
# ActiveRecord::Base.send(:include, Redmine::Acts::Customizable)

require 'ayty_application_controller_patch'
require 'ayty_attachments_controller_patch'
require 'ayty_context_menus_controller_patch'
require 'ayty_issues_controller_patch'
require 'ayty_journals_controller_patch'
require 'ayty_principal_memberships_controller_patch'
require 'ayty_reports_controller_patch'
require 'ayty_users_controller_patch'
require 'ayty_watchers_controller_patch'

require 'ayty_attachment_patch'
require 'ayty_custom_field_patch'
require 'ayty_custom_value_patch'
require 'ayty_enumeration_patch'
require 'ayty_issue_patch'
require 'ayty_issue_priority_patch'
require 'ayty_issue_query_patch'
require 'ayty_issue_relation_patch'
require 'ayty_journal_patch'
require 'ayty_member_patch'
require 'ayty_member_role_patch'
require 'ayty_principal_patch'
require 'ayty_project_patch'
require 'ayty_role_patch'
require 'ayty_time_entry_query_patch'
require 'ayty_time_entry_patch'
require 'ayty_user_patch'
require 'ayty_version_patch'

require 'ayty_application_helper_patch'
require 'ayty_custom_fields_helper_patch'
require 'ayty_issues_helper_patch'
require 'ayty_journals_helper_patch'

require_dependency 'ayty_custom_code_hooks'

Redmine::Plugin.register :ayty_custom_code do
  name 'Ayty Custom Code plugin'
  author 'Silvio Fernandes'
  description 'This is a plugin for Redmine'
  version '1.1.0'
  url 'http://helpdesk.aytycrm.com.br'
  author_url 'https://br.linkedin.com/pub/silvio-fernandes/13/3b7/937'

  requires_redmine version_or_higher: '3.0.0'

  menu :admin_menu,
       :ayty_roles,
       { controller: 'ayty_roles' },
       caption: :label_ayty_roles_plural

  menu :admin_menu,
       :ayty_access_levels,
       { controller: 'ayty_access_levels' },
       caption: :label_ayty_access_levels_plural

  menu :admin_menu,
       :ayty_manager_users,
       { controller: :users, action: :index_manager },
       caption: :label_ayty_manager_users_plural

  menu :admin_menu,
       :ayty_managed_roles,
       { controller: 'ayty_managed_roles' },
       caption: :label_ayty_managed_roles_plural

  menu :admin_menu,
       :ayty_time_entry_types,
       { controller: 'ayty_time_entry_types' },
       caption: :label_ayty_time_entry_types_plural

  menu :account_menu,
       :ayty_issue_priorities,
       { controller: 'ayty_issue_priorities' },
       caption: :label_list_ayty_users,
       first: true,
       html: { remote: true, onclick: "$('#list_users_ayty').toggle()" },
       if: proc { User.current.logged? && User.current.ayty_is_user_ayty? }

  menu :top_menu,
       :ayty_dashboards,
       { controller: 'ayty_dashboards' },
       if: proc { User.current.logged? && User.current.ayty_is_user_ayty? },
       last: true,
       html: { title: 'AytyDashboard' }

  # Rails.application.config.after_initialize do
  #   require 'ayty_issues_helper_patch'
  # end
end

ActionView::Base.send(:include, AytyAccessLevelsHelper)
ActionView::Base.send(:include, ::AytyIssueAlertImagesHelper)
ActionView::Base.send(:include, AytyIssuePrioritiesHelper)
ActionView::Base.send(:include, AytyRolesHelper)
ActionView::Base.send(:include, AytyTemplateNotesHelper)
ActionView::Base.send(:include, AytyTimeEntryTypesHelper)
