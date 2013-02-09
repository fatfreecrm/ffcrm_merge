(($j) ->

  # Fires a request similar to the 'edit' link, but sets the edit_action
  # to 'merge', and defines which asset to merge with.
  crm.load_merge_form = (klass, master_id, dup_id, previous) ->
    $j.ajax(
      url: '/merge/' + klass + '/' + dup_id + '/into/' + master_id
      dataType: "script"
      data:
        previous : previous
    )

  crm.merge_link = ->
    link = $j(this)
    return if link.hasClass('merge-link-applied')
    link.addClass('merge-link-applied')
    row_id = link.attr('data-merge')
    klass = row_id.split('_')[0]
    id = row_id.split('_')[1]

    new crm.Popup({
      trigger     : link.attr('id')
      target      : "jumpbox"
      under       : row_id
      appear      : 0.3
      fade        : 0.3
      before_show : ->
        $("jumpbox_menu").hide()
        $("jumpbox_label").innerHTML = 'Which ' + klass + ' would you like to merge into?'
        $("jumpbox_label").show()
        crm.auto_complete(klass + 's', id, false, "merge")
        # override the afterUpdateElement function to display the merge content
        crm.autocompleter.options.afterUpdateElement = (text, el) ->
          crm.load_merge_form(klass, escape(el.id), id, row_id)
      after_show  : ->
        $("auto_complete_query").focus()
      after_hide  : ->
    })

  # Apply pop up to merge links when document is loaded
  $j(document).ready ->
    $j("a[data-merge]").each(crm.merge_link)

  # Apply pop up to merge links when jquery event (e.g. search) occurs
  $j(document).ajaxComplete ->
    $j("a[data-merge]").each(crm.merge_link)

  # Apply pop up to merge links when protoype event (e.g. cancel edit) occurs
  Ajax.Responders.register({
    onComplete: ->
      $j("a[data-merge]").each(crm.merge_link)
  })

) jQuery
