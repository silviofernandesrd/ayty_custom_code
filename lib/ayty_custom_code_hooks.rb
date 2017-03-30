##### AYTYCRM - Silvio Fernandes #####

# This class hooks into Redmine's View Listeners in order to add content to the page
class AytyCustomCodeHooks < Redmine::Hook::ViewListener

  # ayty custom fields
  render_on :view_custom_fields_form_upper_box, :partial => 'custom_fields/ayty_custom_fields'

  render_on :view_issues_form_details_bottom, :partial => 'issues/ayty_attributes'
  render_on :view_issues_show_details_bottom, :partial => 'issues/ayty_show'
  render_on :view_issues_context_menu_start, :partial => 'context_menus/ayty_issues'

  render_on :view_layouts_base_body_bottom, :partial => 'ayty_issue_priorities/list_ayty_users'

  render_on :view_issue_statuses_form, :partial => 'issue_statuses/ayty_attributes'

  render_on :view_timelog_edit_form_bottom, :partial => 'timelog/ayty_attributes'
  render_on :view_time_entries_bulk_edit_details_bottom, :partial => 'timelog/ayty_bulk_attributes'

  render_on :view_users_form, :partial => 'users/ayty_custom_fields'
  render_on :view_account_right_bottom, :partial => 'users/ayty_custom_show'

  def view_layouts_base_html_head(context = {})
      css = stylesheet_link_tag 'ayty_custom_code.css', :plugin => 'ayty_custom_code'
      js = javascript_include_tag 'ayty_custom_code.js', :plugin => 'ayty_custom_code'
      css + js
  end

  # call hook para salvar os dados do apontamento em um atributo auxiliar da issue
  # com isso estes dados ficam acessiveis na classe da issue
  def controller_issues_edit_before_save(context={ })

    issue = context[:issue]
    time_entry = context[:time_entry]

    if issue && time_entry
      # insere os dados no atributo auxiliar
      issue.ayty_before_time_entry = time_entry
    end

  end

  # call_hook issue
  # Insere mensagens de WARNING para lembra o usuario de apontar Tempo Restante
  def controller_issues_edit_after_save(context={ })
    if context[:time_entry] && context[:time_entry][:hours].present?
      if(context[:time_entry].user_id == context[:issue].assigned_to_id && context[:time_entry].activity.name[0..2].include?("BD"))
        context[:controller].flash[:warning] = l(:notice_ayty_remember_fill_rest_bd,
                                                 :hours => ( context[:issue].ayty_get_value_by_custom_field_name("Tempo Restante BD",
                                                                                                                 context[:issue].ayty_get_value_by_custom_field_name("Estimativa BD - hr", 0)).to_f -
                                                     context[:time_entry][:hours].to_f))
      end
      if(context[:time_entry].user_id == context[:issue].assigned_to_id && context[:time_entry].activity.name[0..2].include?("SIS"))
        context[:controller].flash[:warning] = l(:notice_ayty_remember_fill_rest_sys,
                                                 :hours => ( context[:issue].ayty_get_value_by_custom_field_name("Tempo Restante SIS",
                                                                                                                 context[:issue].ayty_get_value_by_custom_field_name("Estimativa SIS - hr", 0)).to_f -
                                                     context[:time_entry][:hours].to_f))
      end
    end
  end

  # call_hook timelog
  # Insere mensagens de WARNING para lembra o usuario de apontar Tempo Restante
  def controller_timelog_edit_before_save(context={ })
    if context[:time_entry] && context[:time_entry][:hours].present?
      if(context[:time_entry].user_id == context[:time_entry].issue.assigned_to_id && context[:time_entry].activity.name[0..2].include?("BD"))
        context[:controller].flash[:warning] = l(:notice_ayty_remember_fill_rest_bd,
                                                 :hours => (context[:time_entry].issue.ayty_get_value_by_custom_field_name("Tempo Restante BD",
                                                            context[:time_entry].issue.ayty_get_value_by_custom_field_name("Estimativa BD - hr", 0)).to_f -
                                                            context[:time_entry][:hours].to_f))
      end
      if(context[:time_entry].user_id == context[:time_entry].issue.assigned_to_id && context[:time_entry].activity.name[0..2].include?("SIS"))
        context[:controller].flash[:warning] = l(:notice_ayty_remember_fill_rest_sys,
                                                 :hours => (context[:time_entry].issue.ayty_get_value_by_custom_field_name("Tempo Restante SIS",
                                                            context[:time_entry].issue.ayty_get_value_by_custom_field_name("Estimativa SIS - hr", 0)).to_f -
                                                            context[:time_entry][:hours].to_f))
      end
    end
  end

end
