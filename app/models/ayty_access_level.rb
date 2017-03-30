# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

##### AYTYCRM - Silvio Fernandes #####
class AytyAccessLevel < ActiveRecord::Base
  
  has_many :principals
  has_many :users
  has_many :journals
  has_many :attachments
  has_many :custom_fields

  attr_accessible :name, :level, :ayty_access
  
  ##### AYTYCRM - Silvio Fernandes #####
  # Relacionamento para Impedimentos
  # has_many :ayty_impediments
  
  validates_presence_of :name, :level
  validates_numericality_of :level

end
