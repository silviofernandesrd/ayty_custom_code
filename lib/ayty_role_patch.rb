##### AYTYCRM - Silvio Fernandes #####
require_dependency 'role'

module AytyRolePatch
  extend ActiveSupport::Concern

  included do
    class_eval do

      has_and_belongs_to_many :ayty_managed_roles, :class_name => 'Role',
                              :join_table => "#{table_name_prefix}ayty_managed_roles#{table_name_suffix}",
                              :association_foreign_key => "managed_role_id"

    end
  end
end

Role.send :include, AytyRolePatch
