ApplicationHelper.class_eval do
  def ayty_principals_options_for_select(collection, selected=nil, issue=nil)
    options = ''
    user_current = User.current

    if collection.include?(user_current)
      options << content_tag('option', "<< #{l(:label_me)} >>", value: user_current.id)
    end

    if issue
      assigned_to = issue.assigned_to
      if assigned_to
        if collection.include?(assigned_to)
          options << content_tag('option', "<< #{l(:field_assigned_to)} >>", value: issue.assigned_to_id)
        end
      end

      author = issue.author
      if author
        if collection.include?(author)
          options << content_tag('option', "<< #{l(:label_author)} >>", value: issue.author_id)
        end
      end
    end

    groups = ''
    collection.sort.each do |element|
      selected_attribute = ' selected="selected"' if option_value_selected?(element, selected) || element.id.to_s == selected
      (element.is_a?(Group) ? groups : options) << %(<option value="#{element.id}"#{selected_attribute}>#{h element.name}</option>)
    end
    unless groups.empty?
      options << %(<optgroup label="#{h(l(:label_group_plural))}">#{groups}</optgroup>)
    end
    options.html_safe
  end

  # Retorna Array com Niveis de Acesso para um Select
  def render_list_ayty_user_as_link_to_issue_priority
    ayty_users = User.ayty_users
    links = ''
    if ayty_users.any?
      ayty_users.each do |user|
        links += content_tag(:p) do
          link_to(user.name, { controller: :ayty_issue_priorities,
                               id: user.id },
                  onclick: "$('#list_users_ayty').toggle()")
        end
      end
    end
    links.html_safe
  end

  # override
  def authoring(created, author, options={})
    l(options[:label] || :label_added_time_by, :author => link_to_user(author), :age => ayty_time_tag(created)).html_safe
  end

  # metodo para retornar a data em DD/MM/YYYY HH:mm:ss
  def ayty_time_tag(time)
    text = format_time(time, Time.now)
    if @project
      link_to(text, project_activity_path(@project, :from => User.current.time_to_date(time)), :title => format_time(time))
    else
      content_tag('abbr', text, :title => format_time(time))
    end
  end

end
