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

        jQuery("#tab_related").on("ajax:success", "#relatedResourcesElements", function(e, data) {
            jQuery("#related-resources-status").slideDown(250);

            jQuery("#related-resources-status-message").html((data && data.status && (data.status == 'ok')) ? "Added resource" : "Could not add resource: " + data.error);
            window.setTimeout(function() {
                jQuery("#related-resources-status").slideUp(250);
            }, 3000);
            if(data.status == 'ok') {
                jQuery("#tab_related").html(data.html)
            }
        });

        jQuery("#tab_related").on("ajax:success", ".relatedResourcesRemoveLink", function(e, data) {
            jQuery("#related-resources-status").slideDown(250);

            jQuery("#related-resources-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed resource" : "Could not remove resource: " + data.error);
            window.setTimeout(function() {
                jQuery("#related-resources-status").slideUp(250);
            }, 3000);
            if(data.status == 'ok') {
                jQuery("#tab_related").html(data.html)
            }
        });

        jQuery("#addMediaFormElements").bind("ajax:success", function(event, data, status, xhr) {

            $('#addMediaForm').modal('hide').find("input[type=text], textarea").val("")   // hide add media model

        }).bind("ajax:error", function(event, data, status, xhr) {

            jQuery('#form-status').slideDown(250);
            jQuery('#form-status-message').html("Could not add media: " + data.responseText);
           
            window.setTimeout(function() {
                jQuery('#form-status').slideUp(250);
            }, 36000);

        });
    });
