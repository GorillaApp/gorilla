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
      <tr>
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
      else if datum.name == "sequence" and ! /^[actgACTG]*$/.test(datum.value)
        $('.issues').text('Sequence may only contain actg').show()
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
      G.main_editor.file.processFeatures(data)

