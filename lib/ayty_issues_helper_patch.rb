##### AYTYCRM - Silvio Fernandes #####

include Redmine::Export::PDF

IssuesHelper.class_eval do

  # OVERRIDE
  # Returns an array of users that are proposed as watchers
  # on the new issue form
  def users_for_new_issue_watchers(issue)
    users = issue.watcher_users

    # pega os roles do usuario
    managed_roles = User.current.ayty_managed_roles(issue.project_id)

    ayty_users_filtered_roles = issue.project.users.joins(:members => :roles).ayty_filter_managed_roles(:managed_roles => managed_roles)

    if ayty_users_filtered_roles.count <= 20
      users = (users + ayty_users_filtered_roles.sort).uniq
    end

    users
  end

  # OVERRIDE
  def render_custom_fields_rows(issue)
    values = issue.visible_custom_field_values

    # remove os campos que o usuario nao tem acesso
    values.reject! do |value|
      value.custom_field.ayty_access_level.level > User.current.ayty_access_level.level
    end

    return if values.empty?
    half = (values.size / 2.0).ceil
    issue_fields_rows do |rows|
      values.each_with_index do |value, i|

        # pega a data da ultima atualizacao do campo caso seja necessario mostra-la
        ayty_title_show_last_update = value.custom_field.ayty_show_last_update? ? format_time(issue.ayty_get_last_modification_by_custom_field_name(value.custom_field.name.to_s)) : nil

        css = "cf_#{value.custom_field.id}"
        m = (i < half ? :left : :right)

        #rows.send m, custom_field_name_tag(value.custom_field), show_value(value), :class => css
        rows.send m, custom_field_name_tag(value.custom_field, ayty_title_show_last_update), show_value(value), :class => css
      end
    end
  end

  # Cor nos comentarios
  def ayty_custom_color_journal(journals=nil, user=User.current)
    commands_jquery = ""
    if journals && journals.any?
      color_red = "#800000"
      color_blue = "blue"
      for journal in journals
        if user.ayty_is_user_ayty?
          # usuario ayty
          unless journal.user.ayty_is_user_ayty?
            # comentario cliente
            commands_jquery += "
              $('#change-#{journal.id}').css('color', '#{color_blue}');
              $('#change-#{journal.id}').find('h4').css('color', '#{color_blue}');
              $('#change-#{journal.id}').find('a').css('color', '#{color_blue}');
            "
          else
            unless journal.ayty_is_journal_ayty?
              # comentario visivel ao cliente
              commands_jquery += "
                $('#change-#{journal.id}').css('color', '#{color_red}');
                $('#change-#{journal.id}').find('h4').css('color', '#{color_red}');
                $('#change-#{journal.id}').find('a').css('color', '#{color_red}');
              "
            end
          end
        else
          # usuario cliente
          if journal.user.ayty_is_user_ayty?
            # comentario ayty
            commands_jquery += "
              $('#change-#{journal.id}').css('color', '#{color_red}');
              $('#change-#{journal.id}').find('h4').css('color', '#{color_red}');
              $('#change-#{journal.id}').find('a').css('color', '#{color_red}');
            "
          end
        end
      end
    end

    javascript_tag "$(function ($) {#{commands_jquery}});"
  end

  # Returns the textual representation of a single journal detail
  def show_detail(detail, no_html=false, options={})
    multiple = false
    show_diff = false

    case detail.property
      when 'attr'
        field = detail.prop_key.to_s.gsub(/\_id$/, "")
        label = l(("field_" + field).to_sym)
        case detail.prop_key
          when 'due_date', 'start_date'
            value = format_date(detail.value.to_date) if detail.value
            old_value = format_date(detail.old_value.to_date) if detail.old_value

          # ayty manager priority
          when 'ayty_manager_priority_date'
            value = format_time(detail.value) if detail.value
            old_value = format_time(detail.old_value) if detail.old_value

          ##### AYTYCRM - Silvio Fernandes #####
          #when 'project_id', 'status_id', 'tracker_id', 'assigned_to_id', 'priority_id', 'category_id', 'fixed_version_id'
          when 'project_id', 'status_id', 'tracker_id', 'assigned_to_id', 'priority_id', 'category_id', 'fixed_version_id',
              'assigned_to_bd_id', 'assigned_to_net_id', 'assigned_to_test_id', 'assigned_to_aneg_id', 'assigned_to_areq_id',
              'assigned_to_inf_id', 'ayty_manager_priority_user_id'
            value = find_name_by_reflection(field, detail.value)
            old_value = find_name_by_reflection(field, detail.old_value)

          when 'estimated_hours'
            value = "%0.02f" % detail.value.to_f unless detail.value.blank?
            old_value = "%0.02f" % detail.old_value.to_f unless detail.old_value.blank?

          when 'parent_id'
            label = l(:field_parent_issue)
            value = "##{detail.value}" unless detail.value.blank?
            old_value = "##{detail.old_value}" unless detail.old_value.blank?

          when 'is_private'
            value = l(detail.value == "0" ? :general_text_No : :general_text_Yes) unless detail.value.blank?
            old_value = l(detail.old_value == "0" ? :general_text_No : :general_text_Yes) unless detail.old_value.blank?

          when 'description'
            show_diff = true
        end
      when 'cf'
        custom_field = detail.custom_field
        if custom_field
          label = custom_field.name
          if custom_field.format.class.change_as_diff
            show_diff = true
          else
            multiple = custom_field.multiple?
            value = format_value(detail.value, custom_field) if detail.value
            old_value = format_value(detail.old_value, custom_field) if detail.old_value
          end
        end
      when 'attachment'
        label = l(:label_attachment)
      when 'relation'
        if detail.value && !detail.old_value
          rel_issue = Issue.visible.find_by_id(detail.value)
          value = rel_issue.nil? ? "#{l(:label_issue)} ##{detail.value}" :
              (no_html ? rel_issue : link_to_issue(rel_issue, :only_path => options[:only_path]))
        elsif detail.old_value && !detail.value
          rel_issue = Issue.visible.find_by_id(detail.old_value)
          old_value = rel_issue.nil? ? "#{l(:label_issue)} ##{detail.old_value}" :
              (no_html ? rel_issue : link_to_issue(rel_issue, :only_path => options[:only_path]))
        end
        relation_type = IssueRelation::TYPES[detail.prop_key]
        label = l(relation_type[:name]) if relation_type
    end
    call_hook(:helper_issues_show_detail_after_setting,
              {:detail => detail, :label => label, :value => value, :old_value => old_value })

    label ||= detail.prop_key
    value ||= detail.value
    old_value ||= detail.old_value

    unless no_html
      label = content_tag('strong', label)
      old_value = content_tag("i", h(old_value)) if detail.old_value
      if detail.old_value && detail.value.blank? && detail.property != 'relation'
        old_value = content_tag("del", old_value)
      end
      if detail.property == 'attachment' && value.present? &&
          atta = detail.journal.journalized.attachments.detect {|a| a.id == detail.prop_key.to_i}
        # Link to the attachment if it has not been removed
        value = link_to_attachment(atta, :download => true, :only_path => options[:only_path])
        if options[:only_path] != false && atta.is_text?
          value += link_to(
              image_tag('magnifier.png'),
              :controller => 'attachments', :action => 'show',
              :id => atta, :filename => atta.filename
          )
        end
      else
        value = content_tag("i", h(value)) if value
      end
    end

    if show_diff
      s = l(:text_journal_changed_no_detail, :label => label)
      unless no_html
        diff_link = link_to 'diff',
                            {:controller => 'journals', :action => 'diff', :id => detail.journal_id,
                             :detail_id => detail.id, :only_path => options[:only_path]},
                            :title => l(:label_view_diff)
        s << " (#{ diff_link })"
      end
      s.html_safe
    elsif detail.value.present?
      case detail.property
        when 'attr', 'cf'
          if detail.old_value.present?
            l(:text_journal_changed, :label => label, :old => old_value, :new => value).html_safe
          elsif multiple
            l(:text_journal_added, :label => label, :value => value).html_safe
          else
            l(:text_journal_set_to, :label => label, :value => value).html_safe
          end
        when 'attachment', 'relation'
          l(:text_journal_added, :label => label, :value => value).html_safe
      end
    else
      l(:text_journal_deleted, :label => label, :old => old_value).html_safe
    end
  end

  # Returns a PDF string of a single issue
  def issue_to_pdf(issue, assoc={})
    pdf = ITCPDF.new(current_language)
    pdf.set_title("#{issue.project} - #{issue.tracker} ##{issue.id}")
    pdf.alias_nb_pages
    pdf.footer_date = format_date(Date.today)
    pdf.add_page
    pdf.SetFontStyle('B',11)
    buf = "#{issue.project} - #{issue.tracker} ##{issue.id}"
    pdf.RDMMultiCell(190, 5, buf)
    pdf.SetFontStyle('',8)
    base_x = pdf.get_x
    i = 1
    issue.ancestors.visible.each do |ancestor|
      pdf.set_x(base_x + i)
      buf = "#{ancestor.tracker} # #{ancestor.id} (#{ancestor.status.to_s}): #{ancestor.subject}"
      pdf.RDMMultiCell(190 - i, 5, buf)
      i += 1 if i < 35
    end
    pdf.SetFontStyle('B',11)
    pdf.RDMMultiCell(190 - i, 5, issue.subject.to_s)
    pdf.SetFontStyle('',8)
    pdf.RDMMultiCell(190, 5, "#{format_time(issue.created_on)} - #{issue.author}")
    pdf.ln

    left = []
    left << [l(:field_status), issue.status]

    ##### AYTYCRM - Silvio Fernandes #####
    # caso usuario nao seja ayty remove as informacoes de prioridade
    #left << [l(:field_priority), issue.priority]
    left << [l(:field_priority), issue.priority] if User.current.ayty_is_user_ayty?

    left << [l(:field_assigned_to), issue.assigned_to] unless issue.disabled_core_fields.include?('assigned_to_id')
    left << [l(:field_category), issue.category] unless issue.disabled_core_fields.include?('category_id')
    left << [l(:field_fixed_version), issue.fixed_version] unless issue.disabled_core_fields.include?('fixed_version_id')

    right = []
    right << [l(:field_start_date), format_date(issue.start_date)] unless issue.disabled_core_fields.include?('start_date')
    right << [l(:field_due_date), format_date(issue.due_date)] unless issue.disabled_core_fields.include?('due_date')
    right << [l(:field_done_ratio), "#{issue.done_ratio}%"] unless issue.disabled_core_fields.include?('done_ratio')
    right << [l(:field_estimated_hours), l_hours(issue.estimated_hours)] unless issue.disabled_core_fields.include?('estimated_hours')
    right << [l(:label_spent_time), l_hours(issue.total_spent_hours)] if User.current.allowed_to?(:view_time_entries, issue.project)

    rows = left.size > right.size ? left.size : right.size
    while left.size < rows
      left << nil
    end
    while right.size < rows
      right << nil
    end

    half = (issue.visible_custom_field_values.size / 2.0).ceil
    issue.visible_custom_field_values.each_with_index do |custom_value, i|
      (i < half ? left : right) << [custom_value.custom_field.name, show_value(custom_value, false)]
    end

    if pdf.get_rtl
      border_first_top = 'RT'
      border_last_top  = 'LT'
      border_first = 'R'
      border_last  = 'L'
    else
      border_first_top = 'LT'
      border_last_top  = 'RT'
      border_first = 'L'
      border_last  = 'R'
    end

    rows = left.size > right.size ? left.size : right.size
    rows.times do |i|
      heights = []
      pdf.SetFontStyle('B',9)
      item = left[i]
      heights << pdf.get_string_height(35, item ? "#{item.first}:" : "")
      item = right[i]
      heights << pdf.get_string_height(35, item ? "#{item.first}:" : "")
      pdf.SetFontStyle('',9)
      item = left[i]
      heights << pdf.get_string_height(60, item ? item.last.to_s  : "")
      item = right[i]
      heights << pdf.get_string_height(60, item ? item.last.to_s  : "")
      height = heights.max

      item = left[i]
      pdf.SetFontStyle('B',9)
      pdf.RDMMultiCell(35, height, item ? "#{item.first}:" : "", (i == 0 ? border_first_top : border_first), '', 0, 0)
      pdf.SetFontStyle('',9)
      pdf.RDMMultiCell(60, height, item ? item.last.to_s : "", (i == 0 ? border_last_top : border_last), '', 0, 0)

      item = right[i]
      pdf.SetFontStyle('B',9)
      pdf.RDMMultiCell(35, height, item ? "#{item.first}:" : "",  (i == 0 ? border_first_top : border_first), '', 0, 0)
      pdf.SetFontStyle('',9)
      pdf.RDMMultiCell(60, height, item ? item.last.to_s : "", (i == 0 ? border_last_top : border_last), '', 0, 2)

      pdf.set_x(base_x)
    end

    pdf.SetFontStyle('B',9)
    pdf.RDMCell(35+155, 5, l(:field_description), "LRT", 1)
    pdf.SetFontStyle('',9)

    # Set resize image scale
    pdf.set_image_scale(1.6)
    text = textilizable(issue, :description,
                        :only_path => false,
                        :edit_section_links => false,
                        :headings => false,
                        :inline_attachments => false
    )
    pdf.RDMwriteFormattedCell(35+155, 5, '', '', text, issue.attachments, "LRB")

    unless issue.leaf?
      truncate_length = (!is_cjk? ? 90 : 65)
      pdf.SetFontStyle('B',9)
      pdf.RDMCell(35+155,5, l(:label_subtask_plural) + ":", "LTR")
      pdf.ln
      issue_list(issue.descendants.visible.sort_by(&:lft)) do |child, level|
        buf = "#{child.tracker} # #{child.id}: #{child.subject}".
            truncate(truncate_length)
        level = 10 if level >= 10
        pdf.SetFontStyle('',8)
        pdf.RDMCell(35+135,5, (level >=1 ? "  " * level : "") + buf, border_first)
        pdf.SetFontStyle('B',8)
        pdf.RDMCell(20,5, child.status.to_s, border_last)
        pdf.ln
      end
    end

    relations = issue.relations.select { |r| r.other_issue(issue).visible? }
    unless relations.empty?
      truncate_length = (!is_cjk? ? 80 : 60)
      pdf.SetFontStyle('B',9)
      pdf.RDMCell(35+155,5, l(:label_related_issues) + ":", "LTR")
      pdf.ln
      relations.each do |relation|
        buf = relation.to_s(issue) {|other|
          text = ""
          if Setting.cross_project_issue_relations?
            text += "#{relation.other_issue(issue).project} - "
          end
          text += "#{other.tracker} ##{other.id}: #{other.subject}"
          text
        }
        buf = buf.truncate(truncate_length)
        pdf.SetFontStyle('', 8)
        pdf.RDMCell(35+155-60, 5, buf, border_first)
        pdf.SetFontStyle('B',8)
        pdf.RDMCell(20,5, relation.other_issue(issue).status.to_s, "")
        pdf.RDMCell(20,5, format_date(relation.other_issue(issue).start_date), "")
        pdf.RDMCell(20,5, format_date(relation.other_issue(issue).due_date), border_last)
        pdf.ln
      end
    end
    pdf.RDMCell(190,5, "", "T")
    pdf.ln

    if issue.changesets.any? &&
        User.current.allowed_to?(:view_changesets, issue.project)
      pdf.SetFontStyle('B',9)
      pdf.RDMCell(190,5, l(:label_associated_revisions), "B")
      pdf.ln
      for changeset in issue.changesets
        pdf.SetFontStyle('B',8)
        csstr  = "#{l(:label_revision)} #{changeset.format_identifier} - "
        csstr += format_time(changeset.committed_on) + " - " + changeset.author.to_s
        pdf.RDMCell(190, 5, csstr)
        pdf.ln
        unless changeset.comments.blank?
          pdf.SetFontStyle('',8)
          pdf.RDMwriteHTMLCell(190,5,'','',
                               changeset.comments.to_s, issue.attachments, "")
        end
        pdf.ln
      end
    end

    if assoc[:journals].present?
      pdf.SetFontStyle('B',9)
      pdf.RDMCell(190,5, l(:label_history), "B")
      pdf.ln
      assoc[:journals].each do |journal|

        ##### AYTYCRM - Silvio Fernandes #####
        journal_details = journal.ayty_filter_details(User.current)

        # Verifica se houve alteração, se não e o usuario não tiver acesso as Notas não exibe nada
        if journal_details.length > 0 || (!journal.notes.blank? && ayty_user_can_view_content?(User.current, journal.ayty_access_level))

          pdf.SetFontStyle('B',8)
          title = "##{journal.indice} - #{format_time(journal.created_on)} - #{journal.user}"

          # Mostra o nivel de acesso caso não seja a visão do cliente.
          title << " #{ayty_get_access_level_name(User.current, journal.ayty_access_level)}"

          title << " (#{l(:field_private_notes)})" if journal.private_notes?
          pdf.RDMCell(190,5, title)
          pdf.ln
          pdf.SetFontStyle('I',8)

          #details_to_strings(journal.visible_details, true).each do |string|
          details_to_strings(journal_details, true).each do |string|

            pdf.RDMMultiCell(190,5, "- " + string)
          end
          if ayty_user_can_view_content?(User.current, journal.ayty_access_level)

            if journal.notes?
              pdf.ln unless journal.details.empty?
              pdf.SetFontStyle('',8)
              text = textilizable(journal, :notes,
                                  :only_path => false,
                                  :edit_section_links => false,
                                  :headings => false,
                                  :inline_attachments => false
              )
              pdf.RDMwriteFormattedCell(190,5,'','', text, issue.attachments, "")
            end
            pdf.ln

          end

        end
      end
    end

    if issue.attachments.any?
      pdf.SetFontStyle('B',9)
      pdf.RDMCell(190,5, l(:label_attachment_plural), "B")
      pdf.ln
      for attachment in issue.attachments

        # Verifica se o usuario não tiver acesso aos anexos não exibe
        if ayty_user_can_view_content?(User.current, attachment.ayty_access_level)

          pdf.SetFontStyle('',8)
          pdf.RDMCell(80,5, attachment.filename)
          pdf.RDMCell(20,5, number_to_human_size(attachment.filesize),0,0,"R")
          pdf.RDMCell(25,5, format_date(attachment.created_on),0,0,"R")
          pdf.RDMCell(65,5, attachment.author.name,0,0,"R")
          pdf.ln
        end
      end
    end
    pdf.output
  end
end