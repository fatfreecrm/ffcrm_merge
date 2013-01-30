Fat Free CRM - Merge Contacts and Accounts
==========================================

This plugin provides functionality to merge duplicate contacts and accounts.


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

New in version 1.3 (steveyken)
==================

* Refactored merge overrides into separate merge_controller
 * This prevents the need to override core edit action in CRM
* Moved to jQuery and Coffeescript
* Overhauled spec tests - using dummy engine application rather than depending on fat_free_crm
* Added merge_hook so you can add your own customisations (see below)

MERGE HOOKS
===========

If your model has extra behaviour that needs to be taken into consideration when performing a merge then you can use the basic merge_hook function defined as a class method on the entity.

This hook is called after the entity is merged but before it is saved. 
Make any changes to 'self' if you want things to persist.

Override as follows:

  Contact.class_eval
    def merge_hook(duplicate)
      # Your custom merge code here... for example:
      # duplicate.custom_association.each do |ca|
        # ca.contact = self; ca.save!
      # end
    end
  end

Be sure your code loads *after* ffcrm_merge has been initialised otherwise it will be replaced with a blank stub method.

TODO
====

* Create a version history note to record the merge
** perhaps put paperclip on AccountAlias and ContactAlias

Copyright (c) 2013 Nathan Broadbent, Stephen Kenworthy. Crossroads Foundation, released under the MIT license
