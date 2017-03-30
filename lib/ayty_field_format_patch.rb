##### AYTYCRM - Silvio Fernandes #####

module Redmine
  module FieldFormat

    class TimelogFormat < Unbounded
      add 'timelog'
      self.searchable_supported = false
      self.form_partial = nil

      def formatted_value(view, custom_field, value, customized=nil, html=false)
        if value.is_a?(String)
          convert_hours = value.to_hours
          if convert_hours.is_a?(Float)
            return convert_hours
          end
        end
        return ""
      end

      def cast_single_value(custom_field, value, customized=nil)
        value.to_hours
      end

      def validate_single_value(custom_field, value, customized=nil)
        convert_hours = value.to_hours

        errs = super
        errs << ::I18n.t('label_ayty_errors_messages_timelog') unless convert_hours.is_a?(Float)
        errs
      end

    end

  end
end
