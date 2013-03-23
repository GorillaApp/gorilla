function json_request(uri, dict, success, failure) {
    $.ajax({
        type: 'POST',
        url: uri,
        data: JSON.stringify(dict),
        contentType: "application/json",
        dataType: "json",
        success: success,
        failure: failure
    });
}
