##### AYTYCRM - Silvio Fernandes #####

class AytyManagedUser < ActiveRecord::Base

  belongs_to :manager_user, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :managed_user, :class_name => 'User', :foreign_key => 'managed_user_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'

end
