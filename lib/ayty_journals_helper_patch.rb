##### AYTYCRM - Silvio Fernandes #####

JournalsHelper.class_eval do

  # OVERRIDE
  def render_notes(issue, journal, options={})
    content = ''

    # permite editar o proprio comentario em até 10 min, depois somente se tiver acesso via permissoes do projeto
    #editable = User.current.logged? && (User.current.allowed_to?(:edit_issue_notes, issue.project) || (journal.user == User.current && User.current.allowed_to?(:edit_own_issue_notes, issue.project)))
    editable = User.current.logged? && (User.current.allowed_to?(:edit_issue_notes, issue.project) ||
                                        (journal.user == User.current && User.current.allowed_to?(:edit_own_issue_notes, issue.project)) ||
                                        (journal.user == User.current && journal.created_on >= DateTime.current().ago(600))
    )

    links = []
    if !journal.notes.blank?
      # link para ocultar comentario
      links << journal_ayty_hidden_link(journal)

      links << journal_ayty_marked_link(journal)

      links << link_to(image_tag('comment.png'),
                       {:controller => 'journals', :action => 'new', :id => issue, :journal_id => journal},
                       :remote => true,
                       :method => 'post',
                       :title => l(:button_quote)) if options[:reply_links]
      links << link_to_in_place_notes_editor(image_tag('edit.png'), "journal-#{journal.id}-notes",
                                             { :controller => 'journals', :action => 'edit', :id => journal, :format => 'js' },
                                             :title => l(:button_edit)) if editable
    end
    content << content_tag('div', links.join(' ').html_safe, :class => 'contextual') unless links.empty?
    content << textilizable(journal, :notes)
    css_classes = "wiki"
    css_classes << " editable" if editable
    content_tag('div', content.html_safe, :id => "journal-#{journal.id}-notes", :class => css_classes)
  end

  # Metodo para retornar um link para ocultar o comentario
  def journal_ayty_hidden_link(object)
    link = link_to('',
                  { :controller => 'journals',
                    :action => ('toggle_journal_ayty_hidden'),
                    :journal_id => object.id},
                    :class => (object.ayty_hidden ? 'icon icon-eye-off' : 'icon icon-eye'),
                    :remote => true)

    content_tag("span", link, :id => "journal-ayty-hidden-#{object.id}")
  end

  def journal_ayty_marked_link(object)
    link = link_to('',
                  { :controller => 'journals',
                    :action => ('toggle_journal_ayty_marked'),
                    :journal_id => object.id},
                    :class => (object.ayty_marked? ? 'icon icon-marked' : 'icon icon-marked-off'),
                    :remote => true)

    content_tag("span", link, :id => "journal-ayty-marked-#{object.id}")
  end


end