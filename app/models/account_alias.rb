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

# If a Account.find(x) raises a error because the account doesn't exist,
# this table will be looked up to see if the account has been previously
# merged into another account.

class AccountAlias < ActiveRecord::Base
  belongs_to :account, :dependent => :destroy

  # has_paper_trail :meta => { :related => :account }, :ignore => [ :id, :created_at, :updated_at ]

  validates_presence_of :account_id, :destroyed_account_id
  
  # Takes a list of ids, returns a list of ids that have been merged 
  # E.g. If ids = [9876, 1111] returns {"9876"=>"1490"}
  def self.ids_with_alias(ids)
    h = {}
    return {} if ids.nil?
    where(:destroyed_account_id => ids).each do |aa|
      h[aa.destroyed_account_id.to_s] = aa.account_id.to_s
    end
    h
  end
  
end
