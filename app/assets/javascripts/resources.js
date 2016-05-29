// Place all the behaviors and hooks related to the matching controller here.#
// All this logic will automatically be available in application.js.

    jQuery(document).ready(function() {
        jQuery("#formattingOptionsFormElements").bind("ajax:success", function(e, data) {
            jQuery("#formatting-options-status").slideDown(250);

            jQuery("#formatting-options-status-message").html((data && data.status && (data.status == 'ok')) ? "Saved settings" : "Could not save settings: " + data.error);
            window.setTimeout(function() {
                jQuery("#formatting-options-status").slideUp(250);
            }, 3000);
        });

        jQuery("#addMediaFormElements").bind("ajax:success", function(event, data, status, xhr) {
            console.log("got", data);
            $('#addMediaForm').modal('hide').find("input[type=text], textarea").val("")   // hide add media model
            //$('#addMediaForm select').prop('selectedIndex', 0); // reset drop-downs
        });
    });