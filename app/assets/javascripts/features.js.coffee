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

reset_library_form = ->

  dropdown = $("#library_name");
  dropdown.children().reset();

  $('#library-form')[0].reset();


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
      else if datum.name == "sequence" and ! /^[actg]*$/.test(datum.value)
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


  $('#library_name').change () ->
    index = $("#library_name").find(':selected').index()
    text = $("#library_name").find(':selected').text()
    window.selected = text
    lib_id = -1
    $.get "/feature_library/getSelected",{ name: text}, (data) ->

      updateFeatures(data.selected);

    $("#allfeaturesdialog").dialog('option', 'title', text);



  $('#library-form').unbind('submit').submit (event) ->
    event.preventDefault()
    formData = $(this).serializeArray()
    save = true
    Libname = null
    uID = null

#    for datum in formData
#      if datum.value == ""
#        $('.issues').text('You must fill in all items').show()
#        save = false
#      if datum.name == "name"
#        Libname = datum.value
#      if datum.name == "user_id"
#        uID = datum.value

    if save
      $.post "/feature_library/add",
            $(this).serialize(),
            ->
              notify("Successfully saved library", "success")
              reset_library_form()


  updateFeatures = (library_id) ->
    $.get "/feature_libraries/" + library_id + "/feature", {feature_library_id: library_id, user_id: user },(data) ->
      window.allFeatures = data.features
      populateTable(window.allFeatures)

  $('#listFeatures').unbind('click').click ->
    if window.allFeatures != null
      populateTable(window.allFeatures)
      $('#allfeaturesdialog').dialog("open")
    $.get "/feature/getAll", {user_id: user}, (data) ->
      window.allFeatures = data.features
      populateTable(window.allFeatures)
      $('#allfeaturesdialog').dialog("open")
