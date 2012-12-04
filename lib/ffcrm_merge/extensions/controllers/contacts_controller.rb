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

ContactsController.class_eval do

  # PUT /contacts/1/merge/2                                                AJAX
  #----------------------------------------------------------------------------
  def merge
    # Prepare the fields we want to ignore from the duplicate contact.
    ignored = {"_self" => params["ignore"]["_self"].map{|k,v| k if v == "yes" }.compact}

    # Prepare the custom fields we want to ignore from duplicate contact's supertags.
    ignored["tags"] = {}
    if params[:ignore]["tags"]
      params[:ignore]["tags"].map do |tag, values|
        ignored["tags"][tag] = values.map{|k,v| k if v == "yes" }.compact
      end
    end

    @master_contact = Contact.my.find(params[:master_id])

    # Reverse the master and duplicate if :reverse_merge is true
    @reverse_merge = params[:reverse_merge] == "true" ? true : false
    c = [@contact, @master_contact]
    duplicate, master = @reverse_merge ? c.reverse : c

    unless duplicate.merge_with(master, ignored)
      @contact.errors.add_to_base(t('assets_merge_error', :assets => "contacts"))
    end
  end
  
  # GET /contacts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    # 'master_contact' lookup for a merge request.
    @master_contact = Contact.my.find(params[:merge_into]) if params[:merge_into]

    @account = @contact.account || Account.new(:user => current_user)
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Contact.my.find_by_id($1) || $1.to_i
    end

    respond_with(@contact)
  end

  #----------------------------------------------------------------------------
  def respond_to_not_found_with_merged(*types)
    if contact_alias = ContactAlias.find_by_destroyed_contact_id(params[:id])
      redirect_to :id => contact_alias.contact_id
    else
      respond_to_not_found_without_merged
    end
  end
  alias_method_chain :respond_to_not_found, :merged
end
