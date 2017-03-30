##### AYTYCRM - Silvio Fernandes #####
require_dependency 'member'

module AytyMemberPatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      alias_method_chain :reload, :ayty_reload

    end
  end

  def reload_with_ayty_reload(*args)
    @ayty_managed_roles = nil

    reload_without_ayty_reload
  end

  def ayty_managed_roles
    @ayty_managed_roles ||= begin
      if principal.try(:admin?)
        Role.givable.to_a
      else
        if roles.empty?
          []
        elsif roles.any?(&:ayty_all_roles_managed?)
          Role.givable.to_a
        else
          roles.to_a
        end
      end
    end
  end
end

Member.send :include, AytyMemberPatch
