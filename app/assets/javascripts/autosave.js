
// Provides user with the option to see their autosaved file, if one exists
//BUG HERE: Displays the files below one another. I tried making edits to edit.css to make the divs side-by-side.
function display_autosave(autosave) {
    if (autosave !== null) {
        var conf = confirm("An autosaved version of this file exists, would you like to see it?");
        if (conf) {
            editor = new GorillaEditor("#ed", doc);
            editor.startEditing();
            editor2 = new GorillaEditor("#ed2", doc_restored);
            editor2.startEditing();
            $("#ed").css("width", "45%")
                    .css("marginLeft", "2%")
                    .css("marginRight", "5%")
                    .css("marginBottom", "2%")
                    .append("<p> ORIGINAL CONTENTS </p>");
            $("#ed2").css("width", "45%")
                     .css("marginBottom", "2%")
                     .append("<p> MOST RECENT AUTOSAVED VERSION </p>");

        } else {
            editor = new GorillaEditor("#ed", doc);
            editor.startEditing();
        }
    } else {
        editor = new GorillaEditor("#ed", doc);
        editor.startEditing();
    }

}

// intiates autosave request to server
function json_request(dict, success, failure) {
    $.ajax({
        type: 'POST',
        url: "autosave",
        data: JSON.stringify(dict),
        contentType: "application/json",
        dataType: "json",
        success: success,
        failure: failure
    });
}


//For debugging purposes. Autosaves the current file manually
$('#autosave').click(function() {
    json_request(params, function(data) { alert("AUTOSAVE SUCCESSFUL"); }, function(err) { alert("not working"); });
});

//For debugging purposes. Deletes the autosaved file from the model.
$('#delete').click(function() {
    json_request(params, function(data) { alert("DELETE SUCCESSFUL"); }, function(err) { alert("not working"); });
});


