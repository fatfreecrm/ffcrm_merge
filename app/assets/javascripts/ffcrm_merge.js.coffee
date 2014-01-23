(($) ->

  window.ffcrm_merge = {}

  ffcrm_merge.load_form = (klass, master_id, dup_id, previous) ->
    $.ajax
      url: '/merge/' + klass + '/' + dup_id + '/into/' + master_id
      dataType: "script"
      data:
        previous : previous

  $(document).on 'click', 'a[data-merge]', (event) ->

    link = $(this)
    return if link.hasClass('merge-link-applied')
    link.addClass('merge-link-applied')
    row_id = link.attr('data-merge')
    klass = row_id.split('_')[0]
    id = row_id.split('_')[1]

    new crm.Popup({
      trigger     : '#' + link.attr('id')
      target      : "#jumpbox"
      under       : '#' + row_id
      appear      : 0.3
      fade        : 0.3
      before_show : ->
        $("#jumpbox_menu").hide()
        $("#jumpbox_label").html('Which ' + klass + ' would you like to merge ' + link.closest('.contact').find('.name a').html() + ' into?')
        $("#jumpbox_label").show()
        $("#auto_complete_query").val('')

        $("#auto_complete_query").autocomplete(
          source: (request, response) =>
            request = {auto_complete_query: request['term'], related: id}
            $.get crm.base_url + "/" + klass + 's' + "/auto_complete.json", request, (data) ->
              response $.map(data, (value, key) ->
                label: value
                value: key
              )
          # Open merge form
          select: (event, ui) => # Binding for this.base_url.
            if ui.item
              ffcrm_merge.load_form(klass, ui.item.value, id, row_id)
        )

      after_show  : ->
        $("#auto_complete_query").focus()
      after_hide  : ->
    }).toggle_popup(event) # fire the pop up


) jQuery
