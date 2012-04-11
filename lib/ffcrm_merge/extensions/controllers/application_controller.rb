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

ApplicationController.class_eval do

  # Overwrite auto_complete just for ContactsController,
  # giving the ability to ignore specific contact ids.
  #----------------------------------------------------
  def auto_complete
    @query = params[:auto_complete_query]
    @auto_complete = hook(:auto_complete, self, :query => @query, :user => @current_user)
    if @auto_complete.empty?
      @auto_complete = klass.my.text_search(@query).limit(params[:limit] || 10)
    else
      @auto_complete = @auto_complete.last
    end

    # Filter out ignored contact(s) if param was given.
    if params[:ignored]
      ignored_ids = params[:ignored].split(",").map{|i| i.to_i }
      @auto_complete = @auto_complete.select{|a| !ignored_ids.include?(a.id) }
    end

    session[:auto_complete] = controller_name.to_sym
    respond_to do |format|
      format.any(:js, :html)   { render :partial => 'auto_complete' }
      format.json { render :json => @auto_complete.inject({}){|h,a| h[a.id] = a.name; h } }
    end
  end
end
