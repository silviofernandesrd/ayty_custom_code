##### AYTYCRM - Silvio Fernandes #####
module AytyTemplateNotesHelper

  def ayty_template_notes_collection_for_select_options

    conditions = User.current.ayty_is_user_ayty? ? "#{AytyTemplateNote.table_name}.ayty = ?" : "#{AytyTemplateNote.table_name}.client = ?"

    AytyTemplateNote.where(conditions, true).order(:name).all.collect { |i| [i.name, i.id] }

  end

end
