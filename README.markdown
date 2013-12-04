Fat Free CRM - Merge Contacts and Accounts
==========================================

This plugin provides functionality to merge duplicate contacts and accounts for FatFreeCRM. It is also possible to extend it to merge other entities.


Usage
=====

When you hover over a contact or account, you will see a 'merge' link next to edit and delete. 
Type in a part of the name of the account or contact, and click the one that matches.
You will see a form with radio buttons, where you can choose the attributes that you want to keep or overwrite.
There is also a "Duplicate <==> Master" link in the top left corner, if you need to reverse which one is merged into the other.

A merge will move all attributes from the duplicate to the master,
including all notes/emails/opportunities/contacts/etc. 

It is also possible to navigate directly to the merge page using:

  http://www.example.com/merge/contacts/1/into/2
  
Aliases
=======
  
Merges are recorded in the ContactAliases and AccountAliases tables respectively. This is particularly
useful for url redirection e.g. if a person goes to the url of a contact who has been merged, the CRM will
redirect to the newly merged object.

The list of aliases is also exposed over an API. This can be used by other systems to update their entries.
Say, for example, you have another system that accesses CRM and stores contact ids. When a merge occurs, you
need to be able to update the other system. The following url call can help with this. (Responds to json)

  http://www.example.com/merge/contact/aliases.js?ids=1,2,3,4,5&api_key=XYZ
  
It will return a json hash of any ids that have been merged. So for example, if contacts 1 and 2 have been merged
into 11 and 12 respectively then the output will be:

  {'1' => '11', '2' => '12'}
 
(Note that references to 3 and 4 are dropped as they have not been merged.)

The API KEY should be added to your settings.yml file in CRM. See config/settings.yml.example for more details.

  
Installation to FatFreeCRM
=====

Simply add to your Gemfile:

```
gem 'ffcrm_merge', :github => 'fatfreecrm/ffcrm_merge'
```

New in version 1.3 (steveyken)
==================

* Refactored merge overrides into separate merge_controller
 * This prevents the need to override core edit action in CRM
* Moved to jQuery and Coffeescript
* Overhauled spec tests - using dummy engine application rather than depending on fat_free_crm
* Abstracted out merge logic so it is easy to write merge code for other entities. Currently we only provide support for contacts and accounts **patches welcome**
* Added merge_hook so you can add your own customisations (see below)
* Fixed bug where account duplicate tags were always ignored
* Fixed bug where assigned_to, user_id and reports_to were not always set correctly
* Added ability to merge addresses visually
* Moved styles out of template and into css
* Custom field labels are translated on merge form
 * Expects the translation lookup path to be 'active_record.attributes.contact.cf_your_custom_field_name'
* Improved subscribed_users formatting
* Fixed javascript bug where not all merge links were yielding popups. (Have to listen for both jQuery and prototype events.)
* Fixed final redirect to merged entity when using direct url to merge (v1.3.1)
* Corrected module namespacing (v1.3.1)
* Made aliases more production ready. Added api_key authentication (see docs)

MERGE HOOKS
===========

If your model has extra behaviour that needs to be taken into consideration when performing a merge then you can use the basic `merge_hook` function defined as a class method on the entity.

This hook is called after the entity is merged but before it is saved. 
Make any changes to 'self' if you want things to persist.

Override as follows:

```
Contact.class_eval
  def merge_hook(duplicate)
    # Your custom merge code here... for example:
    # duplicate.custom_association.each do |ca|
      # ca.contact = self; ca.save!
    # end
  end
end
```

Be sure your code loads *after* ffcrm_merge has been initialised otherwise it will be replaced with a blank stub method.

KNOWN ISSUES
====
* Permissions are NOT merged. The merged record retains permissions of master record.

TODO
====
* When viewing a contact or account, a helper could fire an ajax call that looks for possible merges and returns them on screen. The icon for this could be a discrete (!) exclamation point, which, when clicked on, opens a box of possible merge candidates.
* When clicking the merge button in the contact or account index view, likely candidates for a merge should appear at the top of the box, above the search. Matching should be done on email and phone number.
* Create a version history note to record the merge
 * perhaps put papertail on AccountAlias and ContactAlias. Something like `has_paper_trail :meta => { :related => :account }, :ignore => [ :id, :created_at, :updated_at ]`
* Add email and phone to merge autocomplete to help identify entities

Copyright (c) 2013 Nathan Broadbent, Stephen Kenworthy. Crossroads Foundation, released under the MIT license
