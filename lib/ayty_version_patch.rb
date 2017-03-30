##### AYTYCRM - Silvio Fernandes #####
require_dependency 'version'

module AytyVersionPatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      belongs_to :assigned_to, class_name: "User"

      validates_presence_of :effective_date

      safe_attributes 'ayty_default',
                      'ayty_hours_provided',
                      'ayty_client_view_hours_provided',
                      'assigned_to_id'

      before_save :ayty_validate_default
    end
  end

  # garante que tera somente um valor default por projeto
  def ayty_validate_default
    if ayty_default? && ayty_default_changed?
      Version.where({:project_id => project_id, :ayty_default => true}).update_all({:ayty_default => false})
    end
  end

end

Version.send :include, AytyVersionPatch
