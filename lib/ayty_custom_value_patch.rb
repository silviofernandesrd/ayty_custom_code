##### AYTYCRM - Silvio Fernandes #####
require_dependency 'custom_value'

module AytyCustomValuePatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      before_save :ayty_format_timelog

    end
  end

  def ayty_format_timelog
    if custom_field.format.name == "timelog"
      self.value = (value.is_a?(String) ? (value.to_hours || value) : value)
    end
  end

end

CustomValue.send :include, AytyCustomValuePatch
