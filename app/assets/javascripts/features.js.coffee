populateTbl = ->
  table=document.getElementById("featuresTbl")
  feat = allFeatures[i]

  row=table.insertRow(-1)

  cell1=row.insertCell(0)
  cell2=row.insertCell(1)
  cell3=row.insertCell(2)
  cell4=row.insertCell(3)
  cell5=row.insertCell(4)
  cell6=row.insertCell(5)

  cell1.innerHTML = "ID"
  cell2.innerHTML = "Name"
  cell3.innerHTML = "Sequence"
  cell4.innerHTML = "Forward Color"
  cell5.innerHTML = "Reverse Color"
  cell6.innerHTML = "Delete?"

  for feat in allFeatures
    row=table.insertRow(-1)

    cell1=row.insertCell(0)
    cell2=row.insertCell(1)
    cell3=row.insertCell(2)
    cell4=row.insertCell(3)
    cell5=row.insertCell(4)
    cell6=row.insertCell(5)

    cell1.innerHTML = feat.id
    cell2.innerHTML = feat.name
    cell3.innerHTML = feat.sequence
    cell4.innerHTML = feat.forward_color
    cell5.innerHTML = feat.reverse_color
    cell6.innerHTML = "<a href='/feature/remove?id="+feat.id+"&user_id="+user+"'>Delete Feature</a>"

window.bind_features = ->
  $('#featuredialog').dialog
    autoOpen: false
    show:
      effect: "slide"
      duration: 1000
    hide:
      effect: "drop"
      duration: 1000

  $('#newFeature').click ->
    $('#featuredialog').dialog("open")

  $('#allfeaturesdialog').dialog
    autoOpen: false
    show:
      effect: "slide"
      duration: 1000
    hide:
      effect: "drop"
      duration: 1000

  $('#listFeatures').click ->
    if allFeatures == null
      $.get "/feature/getAll", {user_id: user}, (data) ->
        allFeatures = data.features
        populateTbl()
        $('#allfeaturedialog').dialog("open")
    else
      populateTbl
      $('#allfeaturedialog').dialog("open")
