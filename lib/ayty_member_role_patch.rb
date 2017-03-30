##### AYTYCRM - Silvio Fernandes #####
require_dependency 'member_role'

module AytyMemberRolePatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      has_many :ayty_managed_roles, :foreign_key => :managed_role_id, :primary_key => :role_id

    end
  end
end

MemberRole.send :include, AytyMemberRolePatch
