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

ContactsHelper.module_eval do

  # Adds 'edit_action => merge' to 'link_to_edit' generator.
  def link_to_merge(contact)
    link_to_remote(t(:merge),
      :method => :get,
      :url    => send("edit_contact_path", contact),
      :with   => %Q"{ previous: crm.find_form('edit_contact'),
                      edit_action: 'merge' }"
    )
  end

end

