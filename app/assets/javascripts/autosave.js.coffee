autosave = (file_contents) ->
    # $.post('edit/autosave', function(data) {
    #     $('.result').html(data);
    # });
	$.ajax({
  		type: "POST",
  		url: 'edit/autosave',
  		data: editor.file.serialize(),
	});