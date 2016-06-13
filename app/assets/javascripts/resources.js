// Place all the behaviors and hooks related to the matching controller here.#
// All this logic will automatically be available in application.js.

    jQuery(document).ready(function() {
        //
        // Media list drag and drop
        //
        jQuery("#resource_media_list").sortable().on('sortstop', function(e, ui) {
            var resource_id =  jQuery("#resource_media_list").data("resource_id");
           var ranks = [];
            jQuery("#resource_media_list .mediaListIcon").each(function(k,m) {
               ranks.push(jQuery(m).data('media_id'));
           });

            if (resource_id && (Object.keys(ranks).length > 0)) {
                jQuery.getJSON("/resources/" + resource_id + "/set_media_order", {ranks: ranks}, function(data) {
                    jQuery("#resources-status").slideDown(250);
                    
                    jQuery("#resources-status-message").html((data && data.status && (data.status == 'ok')) ? "Saved media order" : "Could not save media sort order: " + data.error);
                    window.setTimeout(function() {
                        jQuery("#resources-status").slideUp(250);
                    }, 3000);
                });
            }
        });

        //
        // Collection contents list drag and drop
        //
        jQuery("#collection_contents_list").sortable().on('sortstop', function(e, ui) {
            var resource_id =  jQuery("#collection_contents_list").data("resource_id");
            var ranks = [];
            jQuery("#collection_contents_list .collectionContentsItem").each(function(k,m) {
                ranks.push(jQuery(m).data('id'));
            });

            if (resource_id && (Object.keys(ranks).length > 0)) {
                jQuery.getJSON("/resources/" + resource_id + "/set_resource_order", {ranks: ranks}, function(data) {
                    jQuery("#resources-status").slideDown(250);

                    jQuery("#resources-status-message").html((data && data.status && (data.status == 'ok')) ? "Saved media order" : "Could not save media sort order: " + data.error);
                    window.setTimeout(function() {
                        jQuery("#resources-status").slideUp(250);
                    }, 3000);
                });
            }
        });

        //
        // AJAX form handling
        //
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
