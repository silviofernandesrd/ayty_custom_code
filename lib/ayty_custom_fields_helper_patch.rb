##### AYTYCRM - Silvio Fernandes #####

CustomFieldsHelper.class_eval do

  # override
  # Return custom field name tag
  def custom_field_name_tag(custom_field, ayty_title=nil)

    #title = custom_field.description.presence
    title = ayty_title || custom_field.description.presence

    css = title ? "field-description" : nil
    content_tag 'span', custom_field.name, :title => title, :class => css
  end
end