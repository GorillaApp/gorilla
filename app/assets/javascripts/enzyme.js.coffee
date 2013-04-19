populateTable = (enzymes) ->
  tableData = """
  <table>
    <thead>
      <th>
        <td>Name</td>
        <td>Site</td>
        <td>Comment</td>
        <td></td>
      </th>
    </thead>
    <tbody>
  """

  for enz,i in enzymes
    tableData += """
      <tr>
        <td>#{i+1}</td>
        <td>#{enz.name}</td>
        <td>#{enz.site}</td>
        <td>#{enz.comment}</td>
        <td>
          <a style="color:red;text-decoration:none"
            data-id="#{enz.id}"
            data-user-id="#{user}"
            href="#">X</a>
        </td>
      </tr>
    """

  tableData += """
    </tbody>
  </table>
  """

  $("#enzymes-table").html(tableData)

reset_enzymes_form = ->
  $('enzymes-form').each -> $(this).reset()

window.setup_enzymes = ->
  $('#enzymedialog').dialog
    autoOpen: false
    width: 523
    show:
      effect: "slide"
      duration: 1000
    hide:
      effect: "drop"
      duration: 1000

  $('#allenzymesdialog').dialog
    autoOpen: false
    width: 600
    show:
      effect: "slide"
      duration: 1000
    hide:
      effect: "drop"
      duration: 1000

window.bind_enzymes = ->
  $('#enzyme-form').unbind('submit').submit (event) ->
    event.preventDefault()

    $('.issues').hide()

    formData = $(this).serializeArray()

    save = true

    for datum in formData
      if datum.value == ""
        $('.issues').text('You must fill in all items').show()
        save = false
      else if datum.name == "site" and ! /^[actg]*$/.test(datum.value)
        $('.issues').text('Sequence may only contain actg').show()
        save = false

    if save
      $.post "/enzyme/add",
            $(this).serialize(), ->
              notify("Successfully saved enzyme", "success")
              $("#enzymedialog").dialog("close")
              reset_enzymes_form()

  $('#addEnzyme').unbind('click').click ->
    $('#enzymedialog').dialog("open")

  $('#listEnzymes').unbind('click').click ->
    if window.allEnzymes?
      populateTable(window.allEnzymes)
      $('#allenzymesdialog').dialog("open")
    $.get "/enzyme/getAll", {user_id: user}, (data) ->
      window.allEnzymes = data.enzymes
      populateTable(window.allEnzymes)
      $('#allenzymesdialog').dialog("open")
