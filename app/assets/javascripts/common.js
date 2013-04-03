function json_request(type, uri, dict, success, failure) {
    $.ajax({
        type: type,
        url: uri,
        data: JSON.stringify(dict),
        contentType: "application/json",
        dataType: "json",
        success: success,
        failure: failure
    });
}


