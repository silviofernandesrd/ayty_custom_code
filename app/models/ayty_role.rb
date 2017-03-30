##### AYTYCRM - Silvio Fernandes #####

class AytyRole < ActiveRecord::Base
  
  # Relacionamento para Usuarios
  has_many :users
  
  validates_presence_of :name

  attr_accessible :name,
                  :group_name,
                  :active,
                  :allowed_view_dashboard,
                  :allowed_view_baseline,
                  :allowed_send_mail_time_entries,
                  :allowed_save_baseline,
                  :allowed_to_monitor_production,
                  :allowed_issues_highlights
    
end
