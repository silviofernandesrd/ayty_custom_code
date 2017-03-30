##### AYTYCRM - Silvio Fernandes #####
# Model para Ayty Dashboard

class AytyDashboard < ActiveRecord::Base

  validates_presence_of :name

  has_many :ayty_dashboards_users, dependent: :destroy

  attr_accessor :user_id

  def self.get_issues(assigned_to_id)
    issues = Issue.open.
        joins(:custom_values, :priority).
        # left join para pegar a ultima data de atualizacao dos campos de tempo restante
        joins(" LEFT JOIN [journals] ON [journals].[journalized_id] = [issues].[id] AND [journals].[journalized_type] = 'Issue'
                    LEFT JOIN [journal_details] ON [journal_details].[journal_id] = [journals].[id]
                    LEFT JOIN [versions] ON [issues].[fixed_version_id] = [versions].[id] ").
        where(:assigned_to_id => assigned_to_id).
        select("distinct
                    [#{Issue.table_name}].[id],
                    [#{Issue.table_name}].[status_id],
                    [#{Issue.table_name}].[project_id],
                    [#{Issue.table_name}].[subject],
                    [#{Issue.table_name}].[due_date],
                    [#{Issue.table_name}].[was_client_delivery_disapproved],
                    [#{Issue.table_name}].[dt_client_return],
                    [#{Issue.table_name}].[dt_client_return_last],
                    [#{Issue.table_name}].[dt_queue_enter],
                    [#{Version.table_name}].[name] as fixed_version_name,
                    cast(#{IssuePriority.table_name}.position as numeric) as position,
                    max(case when [custom_values].[custom_field_id] = 44	then [custom_values].[value] else '' end) as release_geral_int,
                    max(case when [custom_values].[custom_field_id] = 55	then [custom_values].[value] else '' end) as release_colab_int,
                    max(case when [custom_values].[custom_field_id] = 59 and isnumeric([custom_values].[value]) = 1 then [custom_values].[value] else '0' end) as res_sis,
                    max(case when [custom_values].[custom_field_id] = 30 and isnumeric([custom_values].[value]) = 1	then [custom_values].[value] else '0' end) as est_sis,
                    max(case when [journal_details].[property] = 'cf' and [journal_details].prop_key = '59'	then [journals].[created_on] end) as res_sis_last_created_on,
                    max(case when [custom_values].[custom_field_id] = 61 and isnumeric([custom_values].[value]) = 1	then [custom_values].[value] else '0' end) as res_sis_colab,
                    max(case when [custom_values].[custom_field_id] = 54 and isnumeric([custom_values].[value]) = 1	then [custom_values].[value] else '0' end) as est_sis_colab,
                    max(case when [journal_details].[property] = 'cf' and [journal_details].prop_key = '61' then [journals].[created_on] end) as res_sis_colab_last_created_on,
                    max(case when [custom_values].[custom_field_id] = 58 and isnumeric([custom_values].[value]) = 1	then [custom_values].[value] else '0' end) as res_bd,
                    max(case when [custom_values].[custom_field_id] = 29 and isnumeric([custom_values].[value]) = 1	then [custom_values].[value] else '0' end) as est_bd,
                    max(case when [journal_details].[property] = 'cf' and [journal_details].prop_key = '58'	then [journals].[created_on] end) as res_bd_last_created_on,
                    max(case when [custom_values].[custom_field_id] = 65 and isnumeric([custom_values].[value]) = 1	then [custom_values].[value] else '0' end) as res_infra,
                    max(case when [custom_values].[custom_field_id] = 34 and isnumeric([custom_values].[value]) = 1	then [custom_values].[value] else '0' end) as est_infra,
                    max(case when [journal_details].[property] = 'cf' and [journal_details].prop_key = '65'	then [journals].[created_on] end) as res_infra_last_created_on").
        group(" [#{Issue.table_name}].[id],
                    [#{Issue.table_name}].[status_id],
                    [#{Issue.table_name}].[project_id],
                    [#{Issue.table_name}].[subject],
                    [#{Issue.table_name}].[due_date],
                    [#{Issue.table_name}].[was_client_delivery_disapproved],
                    [#{Issue.table_name}].[dt_client_return],
                    [#{Issue.table_name}].[dt_client_return_last],
                    [#{Issue.table_name}].[dt_queue_enter],
                    [#{Version.table_name}].[name],
                    [#{IssuePriority.table_name}].[position]").
        order("cast(#{IssuePriority.table_name}.position as numeric)")

    sum_time_sis = 0
    sum_time_sis_colab = 0
    sum_time_bd = 0
    sum_time_infra = 0

    issues.each{|i|
      rest_sys = (i.res_sis != '0') ? i.res_sis.to_f : i.est_sis.to_f
      sum_time_sis += rest_sys if rest_sys > 0

      rest_colab = (i.res_sis_colab != '0') ? i.res_sis_colab.to_f : i.est_sis_colab.to_f
      sum_time_sis_colab += rest_colab if rest_colab > 0

      rest_bd = (i.res_bd != '0') ? i.res_bd.to_f : i.est_bd.to_f
      sum_time_bd += rest_bd if rest_bd > 0

      rest_infra = (i.res_infra != '0') ? i.res_infra.to_f : i.est_infra.to_f
      sum_time_infra += rest_infra if rest_infra > 0
    }

    issues_total = {}
    issues_total[:sum_time_sis] = "%.2f" % sum_time_sis
    issues_total[:sum_time_sis_colab] = "%.2f" % sum_time_sis_colab
    issues_total[:sum_time_bd] = "%.2f" % sum_time_bd
    issues_total[:sum_time_infra] = "%.2f" % sum_time_infra

    issues = issues[0,9] if issues

    return issues, issues_total
  end

  def next_position
    if ayty_dashboards_users.present?
      return (ayty_dashboards_users.last.position || 0) + 1
    end
    1
  end

end
