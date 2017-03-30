##### AYTYCRM - Silvio Fernandes #####
module AytyTemplateNotesHelper

  def ayty_template_notes_collection_for_select_options

    conditions = User.current.ayty_is_user_ayty? ? "#{AytyTemplateNote.table_name}.ayty = 1" : "#{AytyTemplateNote.table_name}.client = 1"

    AytyTemplateNote.where(conditions).order(:name).all.collect { |i| [i.name, i.id] }

  end

end
