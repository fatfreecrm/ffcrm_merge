# it is possible this script will execute before jQuery so we wrap it in a setTimeout

defer = (method) ->
    if (window.jQuery)
        method()
    else
        window.setTimeout (-> defer(method)), 50

defer(() ->

  window.ffcrm_merge = {}

  ffcrm_merge.load_form = (klass, master_id, dup_id, previous) ->
    jQuery.ajax
      url: '/merge/' + klass + '/' + dup_id + '/into/' + master_id
      dataType: "script"
      data:
        previous : previous

  jQuery(document).on 'click', 'a[data-merge]', (event) ->

    link = jQuery(this)
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
        jQuery("#jumpbox_menu").hide()
        jQuery("#jumpbox_label").html('Which ' + klass + ' would you like to merge ' + link.closest('ul').next().find('a').html() + ' into?')
        jQuery("#jumpbox_label").show()
        jQuery("#auto_complete_query").val('')

        jQuery("#auto_complete_query").autocomplete(
          source: (request, response) =>
            request = {term: request['term'], related: id}
            jQuery.get crm.base_url + "/" + klass + 's' + "/auto_complete.json", request, (data) ->
              response jQuery.map(data['results'], (item) ->
                label: item['text']
                value: item['id']
              )
          # Open merge form
          select: (event, ui) => # Binding for this.base_url.
            if ui.item
              ffcrm_merge.load_form(klass, ui.item.value, id, row_id)
        )

      after_show  : ->
        jQuery("#auto_complete_query").focus()
      after_hide  : ->
    }).toggle_popup(event) # fire the pop up

)
