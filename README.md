# Fat Free CRM - Merge Contacts and Accounts

This plugin provides functionality to merge duplicate contacts and accounts for FatFreeCrm. It is also possible to extend it to merge other entities.

## Usage


When you hover over a contact or account, you will see a 'merge' link next to edit and delete. 
Type in a part of the name of the account or contact, and click the one that matches.
You will see a form with radio buttons, where you can choose the attributes that you want to keep or overwrite.
There is also a "Duplicate <==> Master" link in the top left corner, if you need to reverse which one is merged into the other.

A merge will move all attributes from the duplicate to the master,
including all notes/emails/opportunities/contacts/etc. 

It is also possible to navigate directly to the merge page using:

  http://www.example.com/merge/contacts/1/into/2
  
## Aliases
  
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

  
## Installation to FatFreeCrm

Simply add to your Gemfile:

```
gem 'ffcrm_merge', github: 'fatfreecrm/ffcrm_merge'
```

## MERGE HOOKS

If your model has extra behaviour that needs to be taken into consideration when performing a merge then you can use the basic `merge_hook` function defined as a class method on the entity.

This hook is called after the entity is merged, just before it is saved. 
Make any changes to 'self' if you want things to persist.

For example:

```
Contact.class_eval
  def merge_hook(duplicate)
    # Your custom merge code here
    # self = master
    duplicate.custom_association.each do |ca|
      ca.contact = self; ca.save!
    end
  end
end
```

Be sure your code loads *after* ffcrm_merge has been initialised otherwise it will be replaced with a blank stub method.

## Development

To run tests:

    rails db:test:prepare
    rspec spec/


## KNOWN ISSUES

* Permissions are NOT merged. The merged record retains permissions of master record.

## TODO

* When viewing a contact or account, a helper could fire an ajax call that looks for possible merges and returns them on screen. The icon for this could be a discrete (!) exclamation point, which, when clicked on, opens a box of possible merge candidates.
* When clicking the merge button in the contact or account index view, likely candidates for a merge should appear at the top of the box, above the search. Matching should be done on email and phone number.
* Create a version history note to record the merge
* perhaps put papertail on AccountAlias and ContactAlias. Something like `has_paper_trail :meta => { :related => :account }, :ignore => [ :id, :created_at, :updated_at ]`
* Add email and phone to merge autocomplete to help identify entities

Copyright (c) Nathan Broadbent, Stephen Kenworthy. Crossroads Foundation, released under the MIT license
