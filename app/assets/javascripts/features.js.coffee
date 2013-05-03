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

window.matched = null
window.currentIndex = 0

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
  # find next will temporaily create an annotated feature
  $('#find-next-button').unbind('click').click ->

    $('.issues').empty()
    search = window.validate()

    if search
      sequence = $('#find_sequence').val()

      if window.matched == null

        isChecked = $('#find-reverse').is(":checked")
        indexes = G.GenBank.indexes(G.main_editor.file.data.raw_genes, sequence)

        if isChecked
          reverseSequence = G.GenBank.getReverseComplement(sequence)
          rIndexes = G.GenBank.indexes(G.main_editor.file.data.raw_genes, reverseSequence)

          console.log("Reverse indexes", rIndexes)
          indexes = rIndexes.concat indexes
          indexes.sort (a , b) -> return a - b

        window.matched = G.main_editor.file.generateFoundFeatureObjects(sequence, indexes)

        if window.matched.length == 0
          $('.issues').text("No Matches Found").show()
          $('.issues').append("<br> <br>")
          return

        window.currentIndex = 0

      else

          G.main_editor.file.removeFromEnd()
          if window.currentIndex == window.matched.length - 1
            window.currentIndex = 0
          else
            window.currentIndex = window.currentIndex + 1

      console.log("Matched", window.matched)
      console.log("Current Index", window.currentIndex)

      G.main_editor.file.pushToFeatureArray(window.matched[window.currentIndex])

      G.main_editor.startEditing()

  $('#find-prev-button').unbind('click').click ->

    $('.issues').empty()

    search = window.validate()

    if search
      sequence = $('#find_sequence').val()

      if window.matched == null

        isChecked = $('#find-reverse').is(":checked")
        indexes = G.GenBank.indexes(G.main_editor.file.data.raw_genes, sequence)

        if isChecked
          reverseSequence = G.GenBank.getReverseComplement(sequence)
          rIndexes = G.GenBank.indexes(G.main_editor.file.data.raw_genes, reverseSequence)

          console.log("Reverse indexes", rIndexes)
          indexes = rIndexes.concat indexes
          indexes.sort (a , b) -> return a - b

        window.matched = G.main_editor.file.generateFoundFeatureObjects(sequence, indexes)

        if window.matched.length == 0
          $('.issues').text("No Matches Found").show()
          $('.issues').append("<br> <br>")
          return

        console.log("This should not show up if we search for a string that does not exist")

        window.currentIndex = 0

        window.matched = G.main_editor.file.generateFoundFeatureObjects(sequence, indexes)
        window.currentIndex = window.matched.length - 1

      else

          G.main_editor.file.removeFromEnd()
          if window.currentIndex == 0
            window.currentIndex = window.matched.length - 1
          else
            window.currentIndex = window.currentIndex - 1

      G.main_editor.file.pushToFeatureArray(window.matched[window.currentIndex])

      G.main_editor.startEditing()

  $('#clear-button').unbind('click').click ->
    window.resetState()

  $('#find-reverse').mousedown(window.resetState)

  $('#finddialog').bind('dialogclose', -> window.onDialogClose)


  $('#find_sequence').bind('input propertychange', window.resetState)

window.onDialogClose ->
  $('#find_sequence').val("")
  window.resetState()



window.resetState = ->
  console.log("State resetting")

  $('.issues').empty()


  if window.matched != null
    window.matched = null
    G.main_editor.file.removeFromEnd()
    currentIndex = 0
    G.main_editor.startEditing()

window.validate = =>
  search = true

  sequence = $('#find_sequence').val()

  # check that the sequence to find is non-empty
  if sequence == ""
    $('.issues').text("You must specify a sequence to find").show()
    $('.issues').append("<br> <br>")
    search = false

  # check that all characters in the sequence are valid
  else if ! /^[actgnACTGN]*$/.test(sequence)
    $('.issues').text("Invalid characters in sequence").show()
    $('.issues').append("<br> <br>")
    search = false

  search

