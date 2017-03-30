##### AYTYCRM - Silvio Fernandes #####
# Model para lastnames da USER

class AytyLastname < ActiveRecord::Base

  scope :active, lambda { where(:active => true) }

  scope :sorted, lambda { order(:lastname) }

end
