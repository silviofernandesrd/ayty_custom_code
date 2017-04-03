class AytyIssuePrioritiesController < ApplicationController

  include ActionView::Context
  include ActionView::Helpers::UrlHelper
  include ::AytyIssueAlertImagesHelper
  include AytyIssuePrioritiesHelper
  include WatchersHelper

  before_filter :validate_ayty_user_access

  def index

    @user = User.find(params[:id])

    @table = Hash.new()

    @table[:id] = "ayty_issue_priorities"

    @table[:class] = "list ayty_issue_priorities_style"

    @table[:tbody] = Hash.new()
    @table[:tbody][:class] = "content_ayty_issue_priorities"

    # header
    @table[:headers] = [
        { :value => "&nbsp;" },
        { :value => "&nbsp;" },
        { :value => l(:label_ayty_issue_priorities_ticket) },
        { :value => l(:label_ayty_issue_priorities_priority) },
        { :value => l(:field_status) },
        { :value => l(:field_project) },
        { :value => l(:field_subject) },
        { :value => l(:label_development_date_short) },
        { :value => l(:field_due_date) },
        { :value => l(:label_ayty_issue_priorities_remainder_time_sis) },
        { :value => l(:label_ayty_issue_priorities_remainder_time_bd) },
        { :value => l(:label_ayty_issue_priorities_remainder_time_sis_colab) },
        { :value => l(:label_ayty_issue_priorities_remainder_time_inf) },
        { :value => l(:label_ayty_issue_priorities_estimated_test) },
        { :value => l(:field_fixed_version) },
        { :value => l(:label_ayty_issue_priorities_release_geral_int) },
        { :value => l(:label_ayty_issue_priorities_release_colab_int) },
        { :value => l(:label_spent_time_pending) },
        { :value => l(:label_spent_time_by_user) },
        { :value => l(:field_created_on) },
        { :value => l(:label_ayty_issue_priorities_responsible_sis) },
        { :value => l(:label_ayty_issue_priorities_responsible_bd) },
        { :value => l(:label_ayty_issue_priorities_responsible_test) },
        { :value => l(:label_ayty_issue_priorities_responsible_areq) },
        { :value => l(:field_ayty_manager_priority_user) },
        { :value => l(:label_updated_time, "*") },
        { :value => l(:label_spent_time) },
        { :value => l(:label_ayty_issue_priorities_estimated_sis) },
        { :value => l(:label_ayty_issue_priorities_estimated_bd) },
        { :value => l(:label_ayty_issue_priorities_estimated_sis_colab) },
        { :value => l(:label_ayty_issue_priorities_estimated_inf) }
    ]

    ayty_issues_assigned_to = Issue.
                            all.
                            open.
                            ayty_issues_priority(@user)

    if ayty_issues_assigned_to

      # ignorar estes IDs em outros GRIDs
      @ayty_exclude_id_issue_priority = ayty_issues_assigned_to.map(&:id).join(',')

      # tickets que o usuario possui pendentes de apontamentos
      ayty_time_trackers_by_user = TimeTracker.all.where(:user_id => @user)

      time_tracker_play = ayty_time_trackers_by_user.where(:paused => 0).first

      @ayty_issue_play = time_tracker_play.issue.id if time_tracker_play

      # tickets que o usuario possui pendentes nas ultimas 36 horas
      time_trackers_by_user_last_hours = ayty_time_trackers_by_user.where('updated_on > ?', 36.hours.ago)

      # variaveis para somas
      sum_est_time_sis = 0
      sum_est_time_bd = 0
      sum_est_time_sis_colab = 0
      sum_est_time_infra = 0
      sum_est_time_test = 0
      sum_remainder_time_sis = 0
      sum_remainder_time_bd = 0
      sum_remainder_time_sis_colab = 0
      sum_remainder_time_infra = 0

      @table[:columns] = Array.new()

      ayty_issues_assigned_to.each_with_index { |issue, index|

        # tratamentos
        issue_subject = issue.subject.length.to_i > 50 ? "#{issue.subject[0,47]}..." : issue.subject

        spent_hours_by_user = issue.ayty_spent_hours_by_user(@user)

        rest_sys_last_created_on = issue.ayty_get_last_modification_by_custom_field_name("Tempo Restante SIS")
        rest_bd_last_created_on = issue.ayty_get_last_modification_by_custom_field_name("Tempo Restante BD")

        est_time_sis = issue.ayty_get_value_by_custom_field_name("Estimativa SIS - hr", 0)
        est_time_bd = issue.ayty_get_value_by_custom_field_name('Estimativa BD - hr',0)
        est_time_sis_colab = issue.ayty_get_value_by_custom_field_name('Estimativa SIS Colab - hr',0)
        est_time_infra = issue.ayty_get_value_by_custom_field_name('Estimativa Infra - hr',0)
        est_time_test = issue.ayty_get_value_by_custom_field_name('Estimativa Teste - hr',0)

        remainder_time_sis = issue.ayty_get_value_by_custom_field_name('Tempo Restante SIS', est_time_sis)
        remainder_time_bd = issue.ayty_get_value_by_custom_field_name('Tempo Restante BD', est_time_bd)
        remainder_time_sis_colab = issue.ayty_get_value_by_custom_field_name('Tempo Restante SIS Colab', est_time_sis_colab)
        remainder_time_infra = issue.ayty_get_value_by_custom_field_name('Tempo Restante Infra', est_time_infra)

        #somas
        sum_est_time_sis += est_time_sis.to_f if est_time_sis.to_f
        sum_est_time_bd += est_time_bd.to_f if est_time_bd.to_f
        sum_est_time_sis_colab += est_time_sis_colab.to_f if est_time_sis_colab.to_f
        sum_est_time_infra += est_time_infra.to_f if est_time_infra.to_f
        sum_est_time_test += est_time_test.to_f if est_time_test.to_f
        sum_remainder_time_sis += remainder_time_sis.to_f if remainder_time_sis.to_f
        sum_remainder_time_bd += remainder_time_bd.to_f if remainder_time_bd.to_f
        sum_remainder_time_sis_colab += remainder_time_sis_colab.to_f if remainder_time_sis_colab.to_f
        sum_remainder_time_infra += remainder_time_infra.to_f if remainder_time_infra.to_f

        column = Hash.new()

        column[:hidden_field] = (view_context.hidden_field_tag "issues[priority][#{index + 1}]", issue.id, :class => "ayty_issue_priority_id")

        column[:style] = ayty_background_issue_priority_for_style(issue, @ayty_issue_play)

        column[:contents] = Array.new()

        column[:contents] << { :value => (view_context.content_tag :label, {:class => "ayty_issue_priorities_handle"}, :for => '' do "[ #{(index + 1).to_s.rjust(2,'0')} ]" end)}

        column[:contents] << { :value => ayty_get_alerts_by_issue(issue, view_context)}

        column[:contents] << { :value => (view_context.link_to issue.id, :controller => 'issues', :action => 'show', :id => issue) }

        column[:contents] << { :value => issue.priority.nil? ? "" : issue.priority.position }

        column[:contents] << { :value => issue.status}

        column[:contents] << { :value => issue.project}

        column[:contents] << { :value => (view_context.link_to issue_subject, :controller => 'issues', :action => 'show', :id => issue), :title => issue.subject}

        column[:contents] << { :value => format_date(issue.development_date), :style => ayty_background_color_sla_for_date(issue.development_date)}

        column[:contents] << { :value => format_date(issue.due_date), :style => ayty_background_color_sla_for_date(issue.due_date)}

        column[:contents] << {  :value => remainder_time_sis,
                                :style => ayty_background_color_for_remainder_time(issue, @user, issue.assigned_to_net, rest_sys_last_created_on, time_trackers_by_user_last_hours),
                                :title => rest_sys_last_created_on}

        column[:contents] << {  :value => remainder_time_bd,
                                :style => ayty_background_color_for_remainder_time(issue, @user, issue.assigned_to_bd, rest_bd_last_created_on, time_trackers_by_user_last_hours),
                                :title => rest_bd_last_created_on}

        column[:contents] << { :value => remainder_time_sis_colab}

        column[:contents] << { :value => remainder_time_infra}

        column[:contents] << { :value => est_time_test}

        column[:contents] << { :value => issue.fixed_version}

        column[:contents] << { :value => issue.ayty_get_value_by_custom_field_name("Release Geral - Interno")}

        column[:contents] << { :value => issue.ayty_get_value_by_custom_field_name("Release Colab - Interno")}

        column[:contents] << { :value => ayty_get_time_spent_user_by_issue(issue, ayty_time_trackers_by_user)}

        column[:contents] << { :value => spent_hours_by_user > 0 ? l_hours(spent_hours_by_user) : "-" }

        column[:contents] << { :value => format_date(issue.created_on)}

        column[:contents] << { :value => issue.assigned_to_net.nil? ? "" : issue.assigned_to_net.name }

        column[:contents] << { :value => issue.assigned_to_bd.nil? ? "" : issue.assigned_to_bd.name }

        column[:contents] << { :value => issue.assigned_to_test.nil? ? "" : issue.assigned_to_test.name }

        column[:contents] << { :value => issue.assigned_to_areq.nil? ? "" : issue.assigned_to_areq.name }

        column[:contents] << { :value => issue.ayty_manager_priority_user.nil? ? "" : issue.ayty_manager_priority_user.name }

        column[:contents] << { :value => issue.ayty_manager_priority_date.nil? ? "" : view_context.time_tag(issue.ayty_manager_priority_date) }

        column[:contents] << { :value => issue.spent_hours > 0 ? l_hours(issue.spent_hours) : "-" }

        column[:contents] << { :value => est_time_sis}

        column[:contents] << { :value => est_time_bd}

        column[:contents] << { :value => est_time_sis_colab}

        column[:contents] << { :value => est_time_infra}

        @table[:columns] << column

      }

      # footer
      @table[:footers] = [
          { :value => "&nbsp;", :colspan => "9" },
          { :value =>  sum_remainder_time_sis },
          { :value =>  sum_remainder_time_bd},
          { :value =>  sum_remainder_time_sis_colab},
          { :value =>  sum_remainder_time_infra},
          { :value =>  sum_est_time_test},
          { :value => "&nbsp;", :colspan => "13" },
          { :value =>  sum_est_time_sis},
          { :value =>  sum_est_time_bd},
          { :value =>  sum_est_time_sis_colab},
          { :value =>  sum_est_time_infra}
      ]
    end

    # issue play
    unless @ayty_exclude_id_issue_priority.include?(@ayty_issue_play.to_s)
      @table_play = Hash.new()

      ayty_issue_play = Issue.find(@ayty_issue_play)

      ayty_time_tracker_play = TimeTracker.where(:issue_id => @ayty_issue_play, :user_id => @user).first

      @table_play[:class] = "list ayty_issue_priorities_style"

      @table_play[:tbody] = Hash.new()
      @table_play[:tbody][:class] = "content_ayty_issue_priorities"

      # header
      @table_play[:headers] = [
          { :value => "&nbsp;" },
          { :value => l(:label_ayty_issue_priorities_ticket) },
          { :value => l(:label_ayty_issue_priorities_priority) },
          { :value => l(:field_status) },
          { :value => l(:field_project) },
          { :value => l(:field_subject) },
          { :value => l(:field_assigned_to) },
          { :value => l(:field_due_date) },
          { :value => l(:field_created_on) },
          { :value => l(:label_spent_time) }
      ]

      if ayty_issue_play

        @table_play[:columns] = Array.new()

        # tratamentos
        issue_subject = ayty_issue_play.subject.length.to_i > 50 ? "#{ayty_issue_play.subject[0,47]}..." : ayty_issue_play.subject

        column = Hash.new()

        column[:style] = "background: #5CACEE"

        column[:contents] = Array.new()

        column[:contents] << { :value => ayty_get_alerts_by_issue(ayty_issue_play, view_context)}

        column[:contents] << { :value => (view_context.link_to ayty_issue_play.id, :controller => 'issues', :action => 'show', :id => ayty_issue_play) }

        column[:contents] << { :value => ayty_issue_play.priority.nil? ? "" : ayty_issue_play.priority.position }

        column[:contents] << { :value => ayty_issue_play.status}

        column[:contents] << { :value => ayty_issue_play.project}

        column[:contents] << { :value => (view_context.link_to issue_subject, :controller => 'issues', :action => 'show', :id => ayty_issue_play), :title => ayty_issue_play.subject}

        column[:contents] << { :value => ayty_issue_play.assigned_to.nil? ? "" : ayty_issue_play.assigned_to.name }

        column[:contents] << { :value => format_date(ayty_issue_play.due_date), :style => ayty_background_color_sla_for_date(ayty_issue_play.due_date)}

        column[:contents] << { :value => format_date(ayty_issue_play.created_on)}

        column[:contents] << { :value => ayty_time_tracker_play.nil? ? "" : ayty_time_tracker_play.time_spent_to_s }

        @table_play[:columns] << column

        # footer
        @table_play[:footers] = {}

      end
    end
  end

  def ayty_render_responsible

    @load_list_responsible = params[:load_list_responsible]

    if @load_list_responsible.to_s == "true"

      @table_responsible = Hash.new()

      @user_id = params[:user_id]

      @ayty_issue_id_play = params[:ayty_issue_id_play]


      # ids excludes
      @ayty_exclude_id_issue_priority = params[:ayty_exclude_id_issue_priority]
      @ayty_exclude_id_issue_watcher = params[:ayty_exclude_id_issue_watcher]

      # tickets que o usuario possui pendentes de apontamentos
      ayty_time_trackers_by_user = TimeTracker.all.where(:user_id => @user_id)

      # Esta consulta e bem especifica, pois possui status com id fixo, revisar depois para melhorar
      ayty_issues_responsible = Issue.
                                  all.
                                  open.
                                  ayty_issues_responsible_open(@user_id).
                                  concat(Issue.all.ayty_issues_responsible_closed(@user_id))

      @table_responsible[:class] = "list ayty_issue_priorities_style"

      @table_responsible[:tbody] = Hash.new()
      @table_responsible[:tbody][:class] = "content_ayty_issue_priorities"

      # header
      @table_responsible[:headers] = [
          { :value => "&nbsp;" },
          { :value => l(:label_ayty_issue_priorities_ticket) },
          { :value => l(:label_ayty_issue_priorities_priority) },
          { :value => l(:field_status) },
          { :value => l(:field_project) },
          { :value => l(:field_subject) },
          { :value => l(:field_assigned_to) },
          { :value => l(:field_due_date) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_sis) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_bd) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_sis_colab) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_inf) },
          { :value => l(:label_ayty_issue_priorities_estimated_test) },
          { :value => l(:field_fixed_version) },
          { :value => l(:label_ayty_issue_priorities_release_geral_int) },
          { :value => l(:label_ayty_issue_priorities_release_colab_int) },
          { :value => l(:label_spent_time_pending) },
          { :value => l(:label_spent_time_by_user) },
          { :value => l(:field_created_on) },
          { :value => l(:label_updated_time, "*") },
          { :value => l(:label_spent_time) },
          { :value => l(:label_ayty_issue_priorities_estimated_sis) },
          { :value => l(:label_ayty_issue_priorities_estimated_bd) },
          { :value => l(:label_ayty_issue_priorities_estimated_sis_colab) },
          { :value => l(:label_ayty_issue_priorities_estimated_inf) }
      ]

      if ayty_issues_responsible

        # ignorar estes IDs em outros GRIDs
        @ayty_exclude_id_issue_responsible = ayty_issues_responsible.map(&:id).join(',')

        @table_responsible[:columns] = Array.new()

        ayty_issues_responsible.each_with_index { |issue, index|

          # tratamentos
          issue_subject = issue.subject.length.to_i > 50 ? "#{issue.subject[0,47]}..." : issue.subject

          spent_hours_by_user = issue.ayty_spent_hours_by_user(@user_id)

          est_time_sis = issue.ayty_get_value_by_custom_field_name("Estimativa SIS - hr", 0)
          est_time_bd = issue.ayty_get_value_by_custom_field_name('Estimativa BD - hr',0)
          est_time_sis_colab = issue.ayty_get_value_by_custom_field_name('Estimativa SIS Colab - hr',0)
          est_time_infra = issue.ayty_get_value_by_custom_field_name('Estimativa Infra - hr',0)
          est_time_test = issue.ayty_get_value_by_custom_field_name('Estimativa Teste - hr',0)

          remainder_time_sis = issue.ayty_get_value_by_custom_field_name('Tempo Restante SIS', est_time_sis)
          remainder_time_bd = issue.ayty_get_value_by_custom_field_name('Tempo Restante BD', est_time_bd)
          remainder_time_sis_colab = issue.ayty_get_value_by_custom_field_name('Tempo Restante SIS Colab', est_time_sis_colab)
          remainder_time_infra = issue.ayty_get_value_by_custom_field_name('Tempo Restante Infra', est_time_infra)

          column = Hash.new()

          column[:style] = ayty_background_list_responsible_for_style(issue, @ayty_issue_id_play)

          column[:contents] = Array.new()

          column[:contents] << { :value => ayty_get_alerts_by_issue(issue, view_context)}

          column[:contents] << { :value => (view_context.link_to issue.id, :controller => 'issues', :action => 'show', :id => issue) }

          column[:contents] << { :value => issue.priority.nil? ? "" : issue.priority.position }

          column[:contents] << { :value => issue.status}

          column[:contents] << { :value => issue.project}

          column[:contents] << { :value => (view_context.link_to issue_subject, :controller => 'issues', :action => 'show', :id => issue), :title => issue.subject}

          column[:contents] << { :value => issue.assigned_to.nil? ? "" : issue.assigned_to.name }

          column[:contents] << { :value => format_date(issue.due_date), :style => ayty_background_color_sla_for_date(issue.due_date)}

          column[:contents] << {  :value => remainder_time_sis}

          column[:contents] << {  :value => remainder_time_bd }

          column[:contents] << { :value => remainder_time_sis_colab}

          column[:contents] << { :value => remainder_time_infra}

          column[:contents] << { :value => est_time_test}

          column[:contents] << { :value => issue.fixed_version}

          column[:contents] << { :value => issue.ayty_get_value_by_custom_field_name("Release Geral - Interno")}

          column[:contents] << { :value => issue.ayty_get_value_by_custom_field_name("Release Colab - Interno")}

          column[:contents] << { :value => ayty_get_time_spent_user_by_issue(issue, ayty_time_trackers_by_user)}

          column[:contents] << { :value => spent_hours_by_user > 0 ? l_hours(spent_hours_by_user) : "-" }

          column[:contents] << { :value => format_date(issue.created_on)}

          # ALTERAR DEPOIS
          # essa coluna ainda nao possui
          #column[:contents] << { :value => issue.date_changed_priority.nil? ? "" : distance_of_time_in_words(Time.now,issue.date_changed_priority) }
          column[:contents] << { :value => ""}

          column[:contents] << { :value => issue.spent_hours > 0 ? l_hours(issue.spent_hours) : "-" }

          column[:contents] << { :value => est_time_sis}

          column[:contents] << { :value => est_time_bd}

          column[:contents] << { :value => est_time_sis_colab}

          column[:contents] << { :value => est_time_infra}

          @table_responsible[:columns] << column

        }

        # footer
        @table_responsible[:footers] = {}

      end
    end
  end

  def ayty_render_time_tracker_pendings
    @load_list_time_tracker_pendings = params[:load_list_time_tracker_pendings]

    if @load_list_time_tracker_pendings.to_s == "true"

      @table_time_tracker_pendings = Hash.new()

      user_id = params[:user_id]

      ayty_issue_id_play = params[:ayty_issue_id_play]

      # ids excludes
      ayty_exclude_id_issue_priority = params[:ayty_exclude_id_issue_priority]
      ayty_exclude_id_issue_responsible = params[:ayty_exclude_id_issue_responsible]
      ayty_exclude_id_issue_watcher = params[:ayty_exclude_id_issue_watcher]
      ayty_exclude_ids = Array.new
      ayty_exclude_ids << ayty_exclude_id_issue_priority if ayty_exclude_id_issue_priority && ayty_exclude_id_issue_priority.length > 0
      ayty_exclude_ids << ayty_exclude_id_issue_responsible if ayty_exclude_id_issue_responsible && ayty_exclude_id_issue_responsible.length > 0
      ayty_exclude_ids << ayty_exclude_id_issue_watcher if ayty_exclude_id_issue_watcher && ayty_exclude_id_issue_watcher.length > 0
      ayty_exclude_ids << ayty_issue_id_play if ayty_issue_id_play && ayty_issue_id_play.length > 0
      ayty_exclude_ids_concat = ayty_exclude_ids.any? ? ayty_exclude_ids.join(",") : ""

      # tickets que o usuario possui pendentes de apontamentos
      ayty_time_trackers_by_user = TimeTracker.all.where(:user_id => user_id)

      ayty_issues_time_tracker_pendings = Issue.
                                            all.
                                            open.
                                            ayty_issues_time_tracker_pendings(user_id).
                                            ayty_exclude_issues_id(ayty_exclude_ids_concat)

      @table_time_tracker_pendings[:class] = "list ayty_issue_priorities_style"

      @table_time_tracker_pendings[:tbody] = Hash.new()
      @table_time_tracker_pendings[:tbody][:class] = "content_ayty_issue_priorities"

      # header
      @table_time_tracker_pendings[:headers] = [
          { :value => "&nbsp;" },
          { :value => l(:label_ayty_issue_priorities_ticket) },
          { :value => l(:label_ayty_issue_priorities_priority) },
          { :value => l(:field_status) },
          { :value => l(:field_project) },
          { :value => l(:field_subject) },
          { :value => l(:field_assigned_to) },
          { :value => l(:field_due_date) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_sis) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_bd) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_sis_colab) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_inf) },
          { :value => l(:label_ayty_issue_priorities_estimated_test) },
          { :value => l(:field_fixed_version) },
          { :value => l(:label_ayty_issue_priorities_release_geral_int) },
          { :value => l(:label_ayty_issue_priorities_release_colab_int) },
          { :value => l(:label_spent_time_pending) },
          { :value => l(:label_spent_time_by_user) },
          { :value => l(:field_created_on) },
          { :value => l(:label_updated_time, "*") },
          { :value => l(:label_spent_time) },
          { :value => l(:label_ayty_issue_priorities_estimated_sis) },
          { :value => l(:label_ayty_issue_priorities_estimated_bd) },
          { :value => l(:label_ayty_issue_priorities_estimated_sis_colab) },
          { :value => l(:label_ayty_issue_priorities_estimated_inf) }
      ]

      if ayty_issues_time_tracker_pendings

        @table_time_tracker_pendings[:columns] = Array.new()

        ayty_issues_time_tracker_pendings.each_with_index { |issue, index|

          # tratamentos
          issue_subject = issue.subject.length.to_i > 50 ? "#{issue.subject[0,47]}..." : issue.subject

          spent_hours_by_user = issue.ayty_spent_hours_by_user(user_id)

          est_time_sis = issue.ayty_get_value_by_custom_field_name("Estimativa SIS - hr", 0)
          est_time_bd = issue.ayty_get_value_by_custom_field_name('Estimativa BD - hr',0)
          est_time_sis_colab = issue.ayty_get_value_by_custom_field_name('Estimativa SIS Colab - hr',0)
          est_time_infra = issue.ayty_get_value_by_custom_field_name('Estimativa Infra - hr',0)
          est_time_test = issue.ayty_get_value_by_custom_field_name('Estimativa Teste - hr',0)

          remainder_time_sis = issue.ayty_get_value_by_custom_field_name('Tempo Restante SIS', est_time_sis)
          remainder_time_bd = issue.ayty_get_value_by_custom_field_name('Tempo Restante BD', est_time_bd)
          remainder_time_sis_colab = issue.ayty_get_value_by_custom_field_name('Tempo Restante SIS Colab', est_time_sis_colab)
          remainder_time_infra = issue.ayty_get_value_by_custom_field_name('Tempo Restante Infra', est_time_infra)

          column = Hash.new()

          column[:style] = ayty_background_list_responsible_for_style(issue, ayty_issue_id_play)

          column[:contents] = Array.new()

          column[:contents] << { :value => ayty_get_alerts_by_issue(issue, view_context)}

          column[:contents] << { :value => (view_context.link_to issue.id, :controller => 'issues', :action => 'show', :id => issue) }

          column[:contents] << { :value => issue.priority.nil? ? "" : issue.priority.position }

          column[:contents] << { :value => issue.status}

          column[:contents] << { :value => issue.project}

          column[:contents] << { :value => (view_context.link_to issue_subject, :controller => 'issues', :action => 'show', :id => issue), :title => issue.subject}

          column[:contents] << { :value => issue.assigned_to.nil? ? "" : issue.assigned_to.name }

          column[:contents] << { :value => format_date(issue.due_date), :style => ayty_background_color_sla_for_date(issue.due_date)}

          column[:contents] << {  :value => remainder_time_sis}

          column[:contents] << {  :value => remainder_time_bd }

          column[:contents] << { :value => remainder_time_sis_colab}

          column[:contents] << { :value => remainder_time_infra}

          column[:contents] << { :value => est_time_test}

          column[:contents] << { :value => issue.fixed_version}

          column[:contents] << { :value => issue.ayty_get_value_by_custom_field_name("Release Geral - Interno")}

          column[:contents] << { :value => issue.ayty_get_value_by_custom_field_name("Release Colab - Interno")}

          column[:contents] << { :value => ayty_get_time_spent_user_by_issue(issue, ayty_time_trackers_by_user)}

          column[:contents] << { :value => spent_hours_by_user > 0 ? l_hours(spent_hours_by_user) : "-" }

          column[:contents] << { :value => format_date(issue.created_on)}

          # ALTERAR DEPOIS
          # essa coluna ainda nao possui
          #column[:contents] << { :value => issue.date_changed_priority.nil? ? "" : distance_of_time_in_words(Time.now,issue.date_changed_priority) }
          column[:contents] << { :value => ""}

          column[:contents] << { :value => issue.spent_hours > 0 ? l_hours(issue.spent_hours) : "-" }

          column[:contents] << { :value => est_time_sis}

          column[:contents] << { :value => est_time_bd}

          column[:contents] << { :value => est_time_sis_colab}

          column[:contents] << { :value => est_time_infra}

          @table_time_tracker_pendings[:columns] << column

        }

        # footer
        @table_time_tracker_pendings[:footers] = {}

      end
    end
  end

  def ayty_render_watcher

    @load_list_watcher = params[:load_list_watcher]

    if @load_list_watcher.to_s == "true"

      @table_watcher = Hash.new()

      @user_id = params[:user_id]
      user = User.find(@user_id)

      # ids excludes
      @ayty_exclude_id_issue_priority = params[:ayty_exclude_id_issue_priority]
      @ayty_exclude_id_issue_responsible = params[:ayty_exclude_id_issue_responsible]
      ayty_exclude_ids = Array.new
      ayty_exclude_ids << @ayty_exclude_id_issue_priority if @ayty_exclude_id_issue_priority && @ayty_exclude_id_issue_priority.length > 0
      ayty_exclude_ids << @ayty_exclude_id_issue_responsible if @ayty_exclude_id_issue_responsible && @ayty_exclude_id_issue_responsible.length > 0
      ayty_exclude_ids_concat = ayty_exclude_ids.any? ? ayty_exclude_ids.join(",") : ""

      # tickets que o usuario possui pendentes de apontamentos
      ayty_time_trackers_by_user = TimeTracker.all.where(:user_id => @user_id)

      @ayty_issue_id_play = params[:ayty_issue_id_play]

      ayty_issues_watcher = Issue.
                              all.
                              open.
                              ayty_issues_watcher(@user_id).
                              ayty_exclude_issues_id(ayty_exclude_ids_concat)

      @table_watcher[:class] = "list ayty_issue_priorities_style"

      @table_watcher[:tbody] = Hash.new()
      @table_watcher[:tbody][:class] = "content_ayty_issue_priorities"

      # header
      @table_watcher[:headers] = [
          { :value => "&nbsp;" },
          { :value => "&nbsp;" },
          { :value => l(:label_ayty_issue_priorities_ticket) },
          { :value => l(:label_ayty_issue_priorities_priority) },
          { :value => l(:field_status) },
          { :value => l(:field_project) },
          { :value => l(:field_subject) },
          { :value => l(:field_assigned_to) },
          { :value => l(:field_due_date) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_sis) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_bd) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_sis_colab) },
          { :value => l(:label_ayty_issue_priorities_remainder_time_inf) },
          { :value => l(:label_ayty_issue_priorities_estimated_test) },
          { :value => l(:field_fixed_version) },
          { :value => l(:label_ayty_issue_priorities_release_geral_int) },
          { :value => l(:label_ayty_issue_priorities_release_colab_int) },
          { :value => l(:label_spent_time_pending) },
          { :value => l(:label_spent_time_by_user) },
          { :value => l(:field_created_on) },
          { :value => l(:label_updated_time, "*") },
          { :value => l(:label_spent_time) },
          { :value => l(:label_ayty_issue_priorities_estimated_sis) },
          { :value => l(:label_ayty_issue_priorities_estimated_bd) },
          { :value => l(:label_ayty_issue_priorities_estimated_sis_colab) },
          { :value => l(:label_ayty_issue_priorities_estimated_inf) }
      ]

      if ayty_issues_watcher

        # ignorar estes IDs em outros GRIDs
        @ayty_exclude_id_issue_watcher = ayty_issues_watcher.map(&:id).join(',')

        @table_watcher[:columns] = Array.new()

        ayty_issues_watcher.each_with_index { |issue, index|

          # tratamentos
          issue_subject = issue.subject.length.to_i > 50 ? "#{issue.subject[0,47]}..." : issue.subject

          spent_hours_by_user = issue.ayty_spent_hours_by_user(@user_id)

          est_time_sis = issue.ayty_get_value_by_custom_field_name("Estimativa SIS - hr", 0)
          est_time_bd = issue.ayty_get_value_by_custom_field_name('Estimativa BD - hr',0)
          est_time_sis_colab = issue.ayty_get_value_by_custom_field_name('Estimativa SIS Colab - hr',0)
          est_time_infra = issue.ayty_get_value_by_custom_field_name('Estimativa Infra - hr',0)
          est_time_test = issue.ayty_get_value_by_custom_field_name('Estimativa Teste - hr',0)

          remainder_time_sis = issue.ayty_get_value_by_custom_field_name('Tempo Restante SIS', est_time_sis)
          remainder_time_bd = issue.ayty_get_value_by_custom_field_name('Tempo Restante BD', est_time_bd)
          remainder_time_sis_colab = issue.ayty_get_value_by_custom_field_name('Tempo Restante SIS Colab', est_time_sis_colab)
          remainder_time_infra = issue.ayty_get_value_by_custom_field_name('Tempo Restante Infra', est_time_infra)

          column = Hash.new()

          column[:style] = ayty_background_list_responsible_for_style(issue, @ayty_issue_id_play)

          column[:contents] = Array.new()

          column[:contents] << { :value => (user == User.current)? watcher_link(issue, user) : view_context.image_tag('fav.png') }

          column[:contents] << { :value => ayty_get_alerts_by_issue(issue, view_context)}

          column[:contents] << { :value => (view_context.link_to issue.id, :controller => 'issues', :action => 'show', :id => issue) }

          column[:contents] << { :value => issue.priority.nil? ? "" : issue.priority.position }

          column[:contents] << { :value => issue.status}

          column[:contents] << { :value => issue.project}

          column[:contents] << { :value => (view_context.link_to issue_subject, :controller => 'issues', :action => 'show', :id => issue), :title => issue.subject}

          column[:contents] << { :value => issue.assigned_to.nil? ? "" : issue.assigned_to.name }

          column[:contents] << { :value => format_date(issue.due_date), :style => ayty_background_color_sla_for_date(issue.due_date)}

          column[:contents] << { :value => remainder_time_sis}

          column[:contents] << { :value => remainder_time_bd }

          column[:contents] << { :value => remainder_time_sis_colab}

          column[:contents] << { :value => remainder_time_infra}

          column[:contents] << { :value => est_time_test}

          column[:contents] << { :value => issue.fixed_version}

          column[:contents] << { :value => issue.ayty_get_value_by_custom_field_name("Release Geral - Interno")}

          column[:contents] << { :value => issue.ayty_get_value_by_custom_field_name("Release Colab - Interno")}

          column[:contents] << { :value => ayty_get_time_spent_user_by_issue(issue, ayty_time_trackers_by_user)}

          column[:contents] << { :value => spent_hours_by_user > 0 ? l_hours(spent_hours_by_user) : "-" }

          column[:contents] << { :value => format_date(issue.created_on)}

          # ALTERAR DEPOIS
          # essa coluna ainda nao possui
          #column[:contents] << { :value => issue.date_changed_priority.nil? ? "" : distance_of_time_in_words(Time.now,issue.date_changed_priority) }
          column[:contents] << { :value => ""}

          column[:contents] << { :value => issue.spent_hours > 0 ? l_hours(issue.spent_hours) : "-" }

          column[:contents] << { :value => est_time_sis}

          column[:contents] << { :value => est_time_bd}

          column[:contents] << { :value => est_time_sis_colab}

          column[:contents] << { :value => est_time_infra}

          @table_watcher[:columns] << column

        }

        # footer
        @table_watcher[:footers] = {}

      end
    end
  end

  def ayty_render_play

    @load_list_play = params[:load_list_play]

    @ayty_issue_id_play = params[:ayty_issue_id_play]

    if @load_list_play.to_s == "true" && @ayty_issue_id_play

      @table_play = Hash.new()

      user_id = params[:user_id]

      # ids excludes
      @ayty_exclude_id_issue_priority = params[:ayty_exclude_id_issue_priority]
      @ayty_exclude_id_issue_responsible = params[:ayty_exclude_id_issue_responsible]
      ayty_exclude_ids = Array.new
      ayty_exclude_ids << @ayty_exclude_id_issue_priority if @ayty_exclude_id_issue_priority && @ayty_exclude_id_issue_priority.length > 0
      ayty_exclude_ids << @ayty_exclude_id_issue_responsible if @ayty_exclude_id_issue_responsible && @ayty_exclude_id_issue_responsible.length > 0
      ayty_exclude_ids_concat = ayty_exclude_ids.any? ? ayty_exclude_ids.join(",") : ""

      unless ayty_exclude_ids_concat.include?(@ayty_issue_id_play)

        ayty_issue_play = Issue.find(@ayty_issue_id_play)

        ayty_time_tracker_play = TimeTracker.where(:issue_id => @ayty_issue_id_play, :user_id => user_id).first

        @table_play[:class] = "list ayty_issue_priorities_style"

        @table_play[:tbody] = Hash.new()
        @table_play[:tbody][:class] = "content_ayty_issue_priorities"

        # header
        @table_play[:headers] = [
            { :value => "&nbsp;" },
            { :value => l(:label_ayty_issue_priorities_ticket) },
            { :value => l(:label_ayty_issue_priorities_priority) },
            { :value => l(:field_status) },
            { :value => l(:field_project) },
            { :value => l(:field_subject) },
            { :value => l(:field_assigned_to) },
            { :value => l(:field_due_date) },
            { :value => l(:field_created_on) },
            { :value => l(:label_spent_time) }
        ]

        if ayty_issue_play

          @table_play[:columns] = Array.new()

          # tratamentos
          issue_subject = ayty_issue_play.subject.length.to_i > 50 ? "#{ayty_issue_play.subject[0,47]}..." : ayty_issue_play.subject

          column = Hash.new()

          column[:style] = "background: #5CACEE"

          column[:contents] = Array.new()

          column[:contents] << { :value => ayty_get_alerts_by_issue(ayty_issue_play, view_context)}

          column[:contents] << { :value => (view_context.link_to ayty_issue_play.id, :controller => 'issues', :action => 'show', :id => ayty_issue_play) }

          column[:contents] << { :value => ayty_issue_play.priority.nil? ? "" : ayty_issue_play.priority.position }

          column[:contents] << { :value => ayty_issue_play.status}

          column[:contents] << { :value => ayty_issue_play.project}

          column[:contents] << { :value => (view_context.link_to issue_subject, :controller => 'issues', :action => 'show', :id => ayty_issue_play), :title => ayty_issue_play.subject}

          column[:contents] << { :value => ayty_issue_play.assigned_to.nil? ? "" : ayty_issue_play.assigned_to.name }

          column[:contents] << { :value => format_date(ayty_issue_play.due_date), :style => ayty_background_color_sla_for_date(ayty_issue_play.due_date)}

          column[:contents] << { :value => format_date(ayty_issue_play.created_on)}

          column[:contents] << { :value => ayty_time_tracker_play.nil? ? "" : ayty_time_tracker_play.time_spent_to_s }

          @table_play[:columns] << column

          # footer
          @table_play[:footers] = {}

        end
      end
    end
  end

  def ayty_update_priorities
    user = User.find(params[:user_id])
    issues_priority = params[:issues][:priority]

    if User.current.ayty_has_permission_to_save_priotity?(user.id)
      if issues_priority.any?
        reduce_position = 0
        issues_priority.each { |priority, issue|

          if issue_updated = Issue.find(issue)

            if issue_updated.assigned_to == user

              if issue_updated.priority

                if issue_updated.priority.position.to_s != priority.to_s
                  priority_new = IssuePriority.find_by_position((priority.to_i)-reduce_position)
                  unless priority_new
                    priority_new = IssuePriority.unscoped.order("#{IssuePriority.table_name}.position DESC").first
                  end

                  unless issue_updated.priority == priority_new

                    ayty_journal = Journal.new(:journalized => issue_updated, :user => User.current, :notes => "")

                    priority_id_old = issue_updated.priority.id

                    # coloca nivel de acesso no comentario
                    ayty_journal.ayty_access_level = ayty_journal.ayty_access_level_default

                    if issue_updated.update_column(:priority_id, priority_new)
                      ayty_journal.details << JournalDetail.new(
                          :property => 'attr',
                          :prop_key => "priority_id",
                          :old_value => priority_id_old,
                          :value => priority_new.id
                      )
                    end

                    ayty_manager_priority_user_id_old = issue_updated.ayty_manager_priority_user_id
                    ayty_manager_priority_user_id_new = User.current.id

                    if ayty_manager_priority_user_id_old != ayty_manager_priority_user_id_new
                      if issue_updated.update_column(:ayty_manager_priority_user_id, ayty_manager_priority_user_id_new)
                        ayty_journal.details << JournalDetail.new(
                            :property => 'attr',
                            :prop_key => "ayty_manager_priority_user_id",
                            :old_value => ayty_manager_priority_user_id_old,
                            :value => ayty_manager_priority_user_id_new
                        )
                      end
                    end

                    # faz um substring depois de converter para remover o tempo do timezone -0200
                    ayty_manager_priority_date_old = issue_updated.ayty_manager_priority_date.to_s(:localdb)[0..18] if issue_updated.ayty_manager_priority_date
                    ayty_manager_priority_date_new = DateTime.now.to_s(:db)

                    if issue_updated.update_column(:ayty_manager_priority_date, ayty_manager_priority_date_new)
                      ayty_journal.details << JournalDetail.new(
                          :property => 'attr',
                          :prop_key => "ayty_manager_priority_date",
                          :old_value => ayty_manager_priority_date_old,
                          :value => ayty_manager_priority_date_new
                      )
                    end

                    ayty_journal.ayty_no_send_mail = true

                    ayty_journal.save!
                  end
                end
              end
            else
              reduce_position += 1
            end
          end
        }
      end
      flash[:notice] = l(:label_ayty_issue_priorities_save_success)
    else
      flash[:error] = l(:notice_not_authorized)
    end
    redirect_to ayty_issue_priorities_path(:id => user)
  end

  def validate_ayty_user_access
    return deny_access unless User.current.ayty_is_user_ayty?
  end
end
