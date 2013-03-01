# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

# If a Contact.find(x) raises a error because the contact doesn't exist,
# this table will be looked up to see if the contact has been previously
# merged into another contact.

class ContactAlias < ActiveRecord::Base
  belongs_to :contact, :dependent => :destroy

  validates_presence_of :contact_id, :destroyed_contact_id

  # Takes a list of ids, returns a list of ids that have been merged 
  # E.g. If ids = [9876, 1111] returns {"9876"=>"1490"}
  def self.ids_with_alias(ids)
    h = {}
    return {} if ids.nil?
    where(:destroyed_contact_id => ids).each do |ca|
      h[ca.destroyed_contact_id.to_s] = ca.contact_id.to_s
    end
    h
  end
end
