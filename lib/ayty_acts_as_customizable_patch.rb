##### AYTYCRM - Silvio Fernandes #####

module Redmine
  module Acts
    module Customizable
      module InstanceMethods

        #override
        #def available_custom_fields
        #  CustomField.ayty_filter_access_level(User.current).where("type = '#{self.class.name}CustomField'").sorted.to_a
        #end

      end
    end
  end
end