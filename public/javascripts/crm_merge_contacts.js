crm.load_merge_form = function(controller, master_id, dup_id, reverse_merge) {
  // Fires a request similar to the 'edit' link,
  // but sets the edit_action to 'merge', and defines
  // which asset to merge with.
  new Ajax.Request('/' + controller + '/' + dup_id + '/edit', {
    asynchronous  : true,
    evalScripts:true,
    method:'get',
    parameters: { previous      : crm.find_form('edit_contact'),
                  edit_action   : 'merge',
                  merge_into    : master_id,
                  reverse_merge : !!reverse_merge }
  });
};

// Added optional 'action' param, to allow a 'merge' callback to
// be fired, as well as the regular 'add asset to related'
// AJAX request. Also added 'ignored_ids' param to specify a collection
// of asset ids to ignore. (Currently only enabled for ContactsController).
//----------------------------------------------------------------------------
crm.auto_complete = function(controller, related, focus, ignored_ids, action) {
  if (this.autocompleter) {
    Event.stopObserving(this.autocompleter.element);
    delete this.autocompleter;
  }

  // Optional 'ignored_ids' param to remove specific asset ids
  // from the autocomplete list.
  var ignored_id_param = ""
  if(ignored_ids){
    ignored_id_param = "?ignored=" + ignored_ids.join(",")
  }

  this.autocompleter = new Ajax.Autocompleter("auto_complete_query", "auto_complete_dropdown", this.base_url + "/" + controller + "/auto_complete" + ignored_id_param, {
    frequency: 0.25,
    afterUpdateElement: function(text, el) {
      if (el.id) {      // Autocomplete entry found.
        if (action == "merge") { // We want to merge assets..
          // In this case, 'related' param is our master asset id.
          // The autocomplete 'el.id' is our duplicate id.
          crm.load_merge_form(controller, escape(el.id), related);
        } else {
          if (related) {  // Attach to related asset.

              new Ajax.Request(this.base_url + "/" + related + "/attach", {
                method     : "put",
                parameters : { assets : controller, asset_id : escape(el.id) },
                onComplete : function() { $("jumpbox").hide(); }
              });
          } else {        // Quick Find: redirect to asset#show.
            window.location.href = this.base_url + "/" + controller + "/" + escape(el.id);
          }
        }
      } else {          // Autocomplete entry not found: refresh current page.
        $("auto_complete_query").value = "";
        window.location.href = window.location.href;
      }
    }.bind(this)        // Binding for this.base_url.
  });
  $("auto_complete_dropdown").update("");
  $("auto_complete_query").value = "";
  if (focus) {
    $("auto_complete_query").focus();
  }
};

