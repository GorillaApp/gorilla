populateTable = (features) ->
  tableData = """
  <table>
    <thead>
      <th>
        <td>Name</td>
        <td>Sequence</td>
        <td>Color</td>
        <td>Reverse Color</td>
        <td></td>
      </th>
    </thead>
    <tbody>
  """

  for feat,i in features
    tableData += """
      <tr data-contents="#{feat.sequence}">
        <td>#{i+1}</td>
        <td>#{feat.name}</td>
        <td>#{feat.sequence}</td>
        <td style="background-color:##{feat.forward_color}">
          #{feat.forward_color}
        </td>
        <td style="background-color:##{feat.reverse_color}">
          #{feat.reverse_color}
        </td>
        <td>
          <a style="color:red;text-decoration:none"
             data-id="#{feat.id}"
             data-user-id="#{user}"
             href="#">X</a>
        </td>
      </tr>
    """

  tableData += """
    </tbody>
  </table>
  """

  $("#features-table").html(tableData)
  $('#features-table').find('a').unbind('click').click (event) ->
    event.preventDefault()
    id = $(this).data('id')
    $.post "/feature/remove",
           id: id,
           ->
             notify("Successfully deleted feature", "success")
             $.get "/feature/getAll", {user_id: user}, (data) ->
               window.allFeatures = data.features
               populateTable(window.allFeatures)
               $('#allfeaturesdialog').dialog("open")

reset_features_form = ->
  $('feature-form').each -> $(this).reset()

window.setup_features = ->
  $('#featuredialog').dialog
    autoOpen: false
    width: 523
    show:
      effect: "slide"
      duration: 1000
    hide:
      effect: "drop"
      duration: 1000

  $('#allfeaturesdialog').dialog
    autoOpen: false
    width: 600
    show:
      effect: "slide"
      duration: 1000
    hide:
      effect: "drop"
      duration: 1000

  $('#finddialog').dialog
    autoOpen: false
    width: 523
    show:
      effect: "slide"
      duration: 1000
    hide:
      effect: "drop"
      duration: 1000

window.handleFileSelect = (evt) ->
  file = evt.target.files[0]
  reader = new FileReader()

  window.reader = reader

  reader.onload = (e) ->
    text = e.target.result
    fileContents = G.main_editor.file.parseFeatureFileContents(text, file.name)
    features = G.main_editor.file.convertToFeatureObjectArray(fileContents)
    populateTable(features)
    $('#allfeaturesdialog').dialog("open")
    G.main_editor.startEditing()


  reader.readAsText(file)


window.bind_features = ->

  $('#feature-form').unbind('submit').submit (event) ->
    event.preventDefault()

    $('.issues').hide()

    formData = $(this).serializeArray()

    save = true

    for datum in formData
      if datum.value == ""
        $('.issues').text('You must fill in all items').show()
        save = false
      else if datum.name == "sequence" and ! /^[actgnACTGN]*$/.test(datum.value)
        $('.issues').text('Sequence may only contain actgn').show()
        save = false

    if save
      $.post "/feature/add",
             $(this).serialize(),
             ->
               notify("Successfully saved feature", "success")
               $("#featuredialog").dialog("close")
               reset_features_form()

  $('#addFeature').unbind('click').click ->
    $('#featuredialog').dialog("open")

  $('#listFeatures').unbind('click').click ->
    if window.allFeatures != null
      populateTable(window.allFeatures)
      $('#allfeaturesdialog').dialog("open")

    $.get "/feature/getAll", {user_id: user}, (data) ->
      window.allFeatures = data.features
      populateTable(window.allFeatures)
      $('#allfeaturesdialog').dialog("open")

  $('#featureLibrary').unbind('click').click ->
    console.log("Making request to the backend for the list of features associated with this user")
    $.get "/feature/getAll", {user_id: user}, (data) ->

      # data: Object (features -> Array of features)
      G.main_editor.file.processFeatures(data.features)
      console.log("Returned Features", data)
      G.main_editor.startEditing()

  $('#upload').unbind('change').bind('change', window.handleFileSelect)

  $('#find').unbind('click').click ->
    $('#finddialog').dialog("open")


  # buttons for search
  $('#find-next-button').unbind('click').click ->


  $('#find-prev-button').unbind('click').click ->

  $('#find-all-button').unbind('click').click ->

  $('#clear-button').unbind('click').click ->
    $('#find-text').val("")



