##### AYTYCRM - Silvio Fernandes #####
require_dependency 'user'

module AytyUserPatch
  extend ActiveSupport::Concern

  included do
    class_eval do
      belongs_to :ayty_access_level, :foreign_key => :ayty_access_level_id

      # Ligação com a Tabela ayty_roles
      belongs_to :ayty_role, :foreign_key => :ayty_role_id

      # acrescentado foreing_key e primary_key para funcionar o relacionamento
      # dependent plugin redmine_time_tracker
      has_many :time_trackers, :foreign_key => :user_id

      # Users Permissions
      has_many :ayty_manager_users,
                :class_name => 'AytyManagedUser',
                :dependent => :destroy

      has_many :ayty_managed_users,
                :foreign_key => :managed_user_id,
                :class_name => 'AytyManagedUser',
                :dependent => :destroy

      has_many :manager_users, :through => :ayty_managed_users

      has_many :managed_users, :through => :ayty_manager_users

      accepts_nested_attributes_for :ayty_managed_users
      accepts_nested_attributes_for :ayty_manager_users

      safe_attributes 'ayty_access_level_id',
                      'ayty_role_id',
                      'days_to_block_retroactive_time_entry',
                      'has_view_time_tracker',
                      'maximum_hours_allowed_to_time_entry_per_day',
                      'is_business_partner',
                      'productive_hours',
                      'days_of_vacation',
                      'code_user',
                      'date_admission',
                      'function_name',
                      'ayty_collaborative',
                      'can_create_ayty_dashboard',
                      'can_update_ayty_dashboard',
                      'can_delete_ayty_dashboard'
    end
  end

  # Metodo que retorna true caso o usuario seja da Ayty
  def ayty_is_user_ayty?
    self.ayty_access_level.ayty_access? if self.ayty_access_level
  end

  def ayty_managed_roles(project)
    if admin?
      @ayty_managed_roles ||= Role.givable.to_a
    else
      membership(project).try(:ayty_managed_roles) || []
    end
  end

  # metodo que valida se o usuario logado pode alterar as prioridades do usuario passado por parametro
  def ayty_has_permission_to_save_priotity?(managed_user_id)
    self.managed_users.map(&:id).include?(managed_user_id) if managed_user_id
  end

  # metodo para replicar roles
  def ayty_replicate_memberships_by_user_id(user_id)
    # usuario usado como replica
    user_stunt = User.find(user_id)

    # apaga todas permissoes
    self.memberships.destroy_all

    # insere as novas permissoes com base no usuario de replica
    user_stunt.memberships.each {|i|
      self.memberships << Member.new(:user => @user, :project => i.project, :roles => i.roles)
    }
    # salva as novas permissoes
    self.save!
  end

  class_methods do
    # Retornar lista de usuarios ayty
    def ayty_users
      active.
      joins(:ayty_access_level).
      where(:ayty_access_levels => {:ayty_access => true}).
      order("case when #{User.table_name}.id = #{User.current.id} then -1 end desc, #{User.table_name}.firstname asc")
    end
  end
end

User.send :include, AytyUserPatch
