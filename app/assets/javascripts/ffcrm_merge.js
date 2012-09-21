crm.load_merge_form = function(controller, master_id, dup_id, reverse_merge) {
  // Fires a request similar to the 'edit' link,
  // but sets the edit_action to 'merge', and defines
  // which asset to merge with.

  // pluralizations for each model.
  var asset_name = {contacts: 'contact',
                    accounts: 'account'}

  new Ajax.Request('/' + controller + '/' + dup_id + '/edit', {
    asynchronous  : true,
    evalScripts:true,
    method:'get',
    parameters: { previous      : crm.find_form('edit_' + asset_name[controller]),
                  edit_action   : 'merge',
                  merge_into    : master_id,
                  reverse_merge : !!reverse_merge }
  });
};

crm.merge_link = function(link) {
  var row_id = link.readAttribute('data-merge'),
      klass = row_id.split('_')[0],
      id = row_id.split('_')[1];

  new crm.Popup({
    trigger     : link.id,
    target      : "jumpbox",
    under       : row_id,
    appear      : 0.3,
    fade        : 0.3,
    before_show : function() {
      $("jumpbox_menu").hide();
      $("jumpbox_label").innerHTML = 'Which '+ klass +' would you like to merge into?'
      $("jumpbox_label").show();
      crm.auto_complete(klass +'s', id, false, "merge");
      // override the afterUpdateElement function to display the merge content
      crm.autocompleter.options.afterUpdateElement = function(text, el) {
        crm.load_merge_form(klass +'s', escape(el.id), id)
      }
    },
    after_show  : function() {
      $("auto_complete_query").focus();
    },
    after_hide  : function() {
    }
  });
};

document.observe('dom:loaded', function() {
  $$("a[data-merge]").each(crm.merge_link);
});
