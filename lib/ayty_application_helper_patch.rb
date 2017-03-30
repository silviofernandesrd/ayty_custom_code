##### AYTYCRM - Silvio Fernandes #####
ApplicationHelper.class_eval do

  # Returns a string for users/groups option tags
  # Override para incluir alem da funcao ME a funcao ASSIGNED_TO
  # pegando o valor do Atribuido Para e adicionandd mais uma opcao se existir
  def ayty_principals_options_for_select(collection, selected=nil, issue=nil)
    s = ''

    # mim
    if collection.include?(User.current)
      s << content_tag('option', "<< #{l(:label_me)} >>", :value => User.current.id)
    end

    if issue
      # atribuido para
      if issue.assigned_to
        if collection.include?(issue.assigned_to)
          s << content_tag('option', "<< #{l(:field_assigned_to)} >>", :value => issue.assigned_to_id)
        end
      end

      # autor
      if issue.author
        if collection.include?(issue.author)
          s << content_tag('option', "<< #{l(:label_author)} >>", :value => issue.author_id)
        end
      end
    end

    groups = ''
    collection.sort.each do |element|
      selected_attribute = ' selected="selected"' if option_value_selected?(element, selected) || element.id.to_s == selected
      (element.is_a?(Group) ? groups : s) << %(<option value="#{element.id}"#{selected_attribute}>#{h element.name}</option>)
    end
    unless groups.empty?
      s << %(<optgroup label="#{h(l(:label_group_plural))}">#{groups}</optgroup>)
    end
    s.html_safe
  end

  # Retorna Array com Niveis de Acesso para um Select
  def render_list_ayty_user_as_link_to_issue_priority(user=User.current)
    ayty_users = User.ayty_users
    links = ''
    if ayty_users.any?
      ayty_users.each {|user|
        links += content_tag(:p) do
          link_to(user.name, {:controller => :ayty_issue_priorities, :id => user.id}, :onclick => "$('#list_users_ayty').toggle()")
        end
      }
    end
    return links.html_safe
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