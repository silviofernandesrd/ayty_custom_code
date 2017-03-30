/* ##### AYTYCRM - Silvio Fernandes ##### */

function addFile(inputEl, file, eagerUpload) {

    if ($('#attachments_fields').children().length < 10) {

        var attachmentId = addFile.nextAttachmentId++;

        var fileSpan = $('<span>', { id: 'attachments_' + attachmentId });
        fileSpan.append(
            $('<input>', { type: 'text', 'class': 'filename readonly', name: 'attachments[' + attachmentId + '][filename]', readonly: 'readonly'} ).val(file.name),
            $('<input>', { type: 'text', 'class': 'description', name: 'attachments[' + attachmentId + '][description]', maxlength: 255, placeholder: $(inputEl).data('description-placeholder') } ).toggle(!eagerUpload),

            /* ##### AYTYCRM - Silvio Fernandes ##### */
            $('<span>('+$("#ayty_attachments_ayty_access_level_id option:selected").text()+')</span>').attr({'class': 'ayty_access_level'}),

            $('<a>&nbsp</a>').attr({ href: "#", 'class': 'remove-upload' }).click(removeFile).toggle(!eagerUpload)
        ).appendTo('#attachments_fields');

        if(eagerUpload) {
            ajaxUpload(file, attachmentId, fileSpan, inputEl);
        }

        return attachmentId;
    }
    return null;
}

addFile.nextAttachmentId = 1;

function uploadBlob(blob, uploadUrl, attachmentId, options) {

    var actualOptions = $.extend({
        loadstartEventHandler: $.noop,
        progressEventHandler: $.noop
    }, options);

    uploadUrl = uploadUrl + '?attachment_id=' + attachmentId;
    if (blob instanceof window.File) {
        uploadUrl += '&filename=' + encodeURIComponent(blob.name);
        uploadUrl += '&content_type=' + encodeURIComponent(blob.type);

        /* ##### AYTYCRM - Silvio Fernandes ##### */
        uploadUrl += '&ayty_access_level_id=' + encodeURIComponent($("#ayty_attachments_ayty_access_level_id").val());
    }

    return $.ajax(uploadUrl, {
        type: 'POST',
        contentType: 'application/octet-stream',
        beforeSend: function(jqXhr, settings) {
            jqXhr.setRequestHeader('Accept', 'application/js');
            // attach proper File object
            settings.data = blob;
        },
        xhr: function() {
            var xhr = $.ajaxSettings.xhr();
            xhr.upload.onloadstart = actualOptions.loadstartEventHandler;
            xhr.upload.onprogress = actualOptions.progressEventHandler;
            return xhr;
        },
        data: blob,
        cache: false,
        processData: false
    });
}