##### AYTYCRM - Silvio Fernandes #####
# Model para Ayty Dashboard

class AytyDashboardsUser < ActiveRecord::Base

  belongs_to :ayty_dashboard

  belongs_to :user

  default_scope { order("position ASC") }

end
