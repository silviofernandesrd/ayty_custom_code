##### AYTYCRM - Silvio Fernandes #####
class AytyTimeEntryType < ActiveRecord::Base

  acts_as_list

  has_many :time_entries

  scope :sorted, lambda { order(:position) }

  scope :active, lambda { where(:active => true) }

  validates_presence_of :name

  def to_s; name end

end
