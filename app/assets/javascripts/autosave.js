
// Provides user with the option to see their autosaved file, if one exists
//BUG HERE: Displays the files below one another. I tried making edits to edit.css to make the divs side-by-side.
function display_autosave(autosave) {
    $('#buttons').hide();
    $('#autosavechoice').hide();
    if (autosave !== null) {
        var conf = confirm("An autosaved version of this file exists, would you like to see it?");
        if (conf) {
            $('#autosavechoice').show();
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
            show_main(doc);
        }
    } else {
        show_main(doc);
    }
}


