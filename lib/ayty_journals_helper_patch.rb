JournalsHelper.class_eval do
  # OVERRIDE
  def render_notes(issue, journal, options={})
    content = ''
    editable = User.current.logged? && (User.current.allowed_to?(:edit_issue_notes, issue.project) ||
                                        (journal.user == User.current && User.current.allowed_to?(:edit_own_issue_notes, issue.project)) ||
                                        (journal.user == User.current && journal.created_on >= 10.minutes.ago)
    )
    links = []
    if !journal.notes.blank?
      links << journal_ayty_hidden_link(journal)

      links << journal_ayty_marked_link(journal)

      links << link_to(l(:button_quote),
                       quoted_issue_path(issue, :journal_id => journal),
                       :remote => true,
                       :method => 'post',
                       :title => l(:button_quote),
                       :class => 'icon-only icon-comment'
                      ) if options[:reply_links]
      links << link_to(l(:button_edit),
                       edit_journal_path(journal),
                       :remote => true,
                       :method => 'get',
                       :title => l(:button_edit),
                       :class => 'icon-only icon-edit'
                      ) if editable
      links << link_to(l(:button_delete),
                       journal_path(journal, :notes => ""),
                       :remote => true,
                       :method => 'put', :data => {:confirm => l(:text_are_you_sure)},
                       :title => l(:button_delete),
                       :class => 'icon-only icon-del'
                      ) if editable
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
