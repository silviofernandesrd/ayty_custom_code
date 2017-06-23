##### AYTYCRM - Silvio Fernandes #####
require_dependency 'principal'

module AytyPrincipalPatch
  extend ActiveSupport::Concern

  included do
    class_eval do
      belongs_to :ayty_access_level, :foreign_key => :ayty_access_level_id

      scope :ayty_filter_access_levels, lambda {|args|
        # filtra somente usuarios ayty
        if args[:ayty_user] == true
          joins(:ayty_access_level).
          where("ayty_access_levels.ayty_access = ?", true)
        end
      }

      scope :ayty_filter_managed_roles, lambda {|args|

        # se algum role possui ayty_all_roles_managed true nao filtra por role_id
        unless args[:managed_roles].any?(&:ayty_all_roles_managed?)
          joins("LEFT JOIN ayty_managed_roles ON ayty_managed_roles.managed_role_id = member_roles.role_id ").
          where("ayty_managed_roles.role_id in (#{args[:managed_roles].map(&:id).join(',')}) ")
        end

      }
    end
  end

end

Principal.send :include, AytyPrincipalPatch
