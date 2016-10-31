// Place all the behaviors and hooks related to the matching controller here.#
// All this logic will automatically be available in application.js.

    jQuery(document).ready(function() {
        //
        // Media list drag and drop
        //
        jQuery("#resource_media_list").sortable();
        jQuery(document).on('sortstop', "#resource_media_list", function(e, ui) {
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
            exchangeLoadMediaForSummernote();
        });

        //
        // Collection contents list drag and drop
        //
        jQuery("#collection_contents_list").sortable();
        jQuery(document).on('sortstop', "#collection_contents_list", function(e, ui) {
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

        jQuery(document).on("ajax:success", "#relatedResourcesElements", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_related").html(data.html)
            }
            jQuery("#related-resources-status").slideDown(250);

            jQuery("#related-resources-status-message").html((data && data.status && (data.status == 'ok')) ? "Added resource" : "Could not add resource: " + data.error);
            window.setTimeout(function() {
                jQuery("#related-resources-status").slideUp(250);
            }, 3000);

        });

        jQuery(document).on("ajax:success", ".relatedResourcesRemoveLink", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_related").html(data.html)
            }
            jQuery("#related-resources-status").slideDown(250);

            jQuery("#related-resources-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed resource" : "Could not remove resource: " + data.error);
            window.setTimeout(function() {
                jQuery("#related-resources-status").slideUp(250);
            }, 3000);

        });

        jQuery("#addMediaFormElements").bind("ajax:success", function(event, data, status, xhr) {

            $('#addMediaForm').modal('hide').find("input[type=text], textarea").val("")   // hide add media modal

        }).bind("ajax:error", function(event, data, status, xhr) {

            jQuery('#form-status').slideDown(250);
            jQuery('#form-status-message').html("Could not add media: " + data.responseText);
           
            jQuery('.tab-pane.active').css("border", "2px solid #cc0000");

            window.setTimeout(function() {
                jQuery('#form-status').slideUp(250);
            }, 36000);

        });

        // Stop Youtube/Soundcloud playback on modal close
        jQuery('.modal').on('hide.bs.modal', function(e) {
           console.log('modal close event');
           jQuery(this).find('iframe').attr('src', jQuery(this).find('iframe').attr('src'));
        });

        //
        // AJAX tagging
        //
        jQuery(document).on("ajax:success", "#addTagsForm", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_tags").html(data.html)
            }
            jQuery("#tags-status").slideDown(250);

            jQuery("#tags-status-message").html((data && data.status && (data.status == 'ok')) ? "Added tag" : "Could not add tag: " + data.error);
            window.setTimeout(function() {
                jQuery("#tags-status").slideUp(250);
            }, 3000);
        });

        jQuery(document).on("ajax:success", ".tagRemoveLink", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_tags").html(data.html)
            }
            jQuery("#tags-status").slideDown(250);

            jQuery("#tags-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed tag" : "Could not remove tag: " + data.error);
            window.setTimeout(function() {
                jQuery("#tags-status").slideUp(250);
            }, 3000);
        });

        //
        // AJAX commenting
        //
        jQuery(document).on("ajax:success", "#addCommentsForm", function(e, data) {
             if(data.status == 'ok') {
                jQuery("#tab_comments").html(data.html)
            }
            jQuery("#comments-status").slideDown(250);

            jQuery("#comments-status-message").html((data && data.status && (data.status == 'ok')) ? "Added comment" : "Could not add comment: " + data.error);
            window.setTimeout(function() {
                jQuery("#comments-status").slideUp(250);
            }, 3000);
        });

        jQuery(document).on("ajax:success", ".commentRemoveLink", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_comments").html(data.html)
            }
            jQuery("#comments-status").slideDown(250);

            jQuery("#comments-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed comment" : "Could not remove comment: " + data.error);
            window.setTimeout(function() {
                jQuery("#comments-status").slideUp(250);
            }, 3000);
        });

        //
        // AJAX links
        //
        jQuery(document).on("ajax:success", "#addLinksForm", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_links").html(data.html)
            }
            jQuery("#links-status").slideDown(250);

            jQuery("#links-status-message").html((data && data.status && (data.status == 'ok')) ? "Added link" : "Could not add link: " + data.error);
            window.setTimeout(function() {
                jQuery("#links-status").slideUp(250);
            }, 3000);
        });

        jQuery(document).on("ajax:success", ".linkRemoveLink", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_links").html(data.html)
            }
            jQuery("#links-status").slideDown(250);

            jQuery("#links-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed link" : "Could not remove link: " + data.error);

            window.setTimeout(function() {
                jQuery("#links-status").slideUp(250);
            }, 3000);
        });

        //
        // AJAX collections
        //

        jQuery(document).on("ajax:success", ".collectionsRemoveLink", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_collections").html(data.html)
            }

            jQuery("#collection-status").slideDown(250);

            jQuery("#collection-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed from collection" : "Could not remove from collection: " + data.error);
            if (data && data.header) {
                jQuery("#resource_title_header").html(data.header);
            }
            if (data && data.resource_collection_select) {
                jQuery("#resource_collection_select_container").html(data.resource_collection_select);
            }

            window.setTimeout(function() {
                jQuery("#collection-status").slideUp(250);
            }, 3000);
        });

        //
        // AJAX add child resource
        //
        jQuery(document).on("ajax:success", "#addChildResourceForm", function(e, data) {
            if(data.status == 'ok') {
                jQuery('#collection_contents_list').html(data.html);
                jQuery('#addChildResourceFormModal').modal('hide');
                jQuery('#add_child_resource_id').val('');
                jQuery('#find_child_resource_id').val('');
            }
            jQuery("#add-child-resource-status").slideDown(250);

            jQuery("#add-child-resource-status-message").html((data && data.status && (data.status == 'ok')) ? "Added resource" : "Could not add resource: " + data.error);
            window.setTimeout(function() {
                jQuery("#add-child-resource-status").slideUp(250);
            }, 3000);
        });

        // AJAX favorite/unfavorite
        //
        //
        jQuery(document).on("ajax:success", "#favoriteControl", function (e, data) {
            if (data.status == 'ok') {
                jQuery("#favoriteControl").html(data.html)
            } else {
                jQuery("#favorite-control-status").slideDown(250).find("#favorite-control-status-message").html(data.message);
                window.setTimeout(function() {
                    jQuery("#favorite-control-status").slideUp(250);
                }, 3000);
            }
        });

        jQuery(document).on("ajax:success", "#unfavoriteControl", function (e, data) {
            if (data.status == 'ok') {
                jQuery("#favoriteControl").html(data.html);
            } else {
                jQuery("#favorite-control-status").slideDown(250).find("#favorite-control-status-message").html(data.message);
                window.setTimeout(function() {
                    jQuery("#favorite-control-status").slideUp(250);
                }, 3000);
            }
        });

        // AJAX user access control
        jQuery(document).on("ajax:success", "#resourceUserAccessElements", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_access").html(data.html)
            }
            jQuery("#access-user-status").slideDown(250);

            jQuery("#access-user-status-message").html((data && data.status && (data.status == 'ok')) ? "Added user" : "Could not add user: " + data.error);
            window.setTimeout(function() {
                jQuery("#access-user-status").slideUp(250);
            }, 3000);

        });

        jQuery(document).on("ajax:success", ".resourceUserAccessRemoveLink", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_access").html(data.html)
            }
            jQuery("#access-user-status").slideDown(250);

            jQuery("#access-user-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed user" : "Could not remove user: " + data.error);
            window.setTimeout(function() {
                jQuery("#access-user-status").slideUp(250);
            }, 3000);

        });

        // AJAX keywords
        jQuery(document).on("ajax:success", "#addTermForm", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_tags").html(data.html)
            }
            jQuery("#terms-status").slideDown(250);

            jQuery("#terms-status-message").html((data && data.status && (data.status == 'ok')) ? "Added keyword" : "Could not add keyword: " + data.error);
            window.setTimeout(function() {
                jQuery("#terms-status").slideUp(250);
            }, 3000);

        });

        jQuery(document).on("ajax:success", ".termRemoveLink", function(e, data) {
            if(data.status == 'ok') {
                jQuery("#tab_tags").html(data.html)
            }
            jQuery("#terms-status").slideDown(250);

            jQuery("#terms-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed keyword" : "Could not remove keyword: " + data.error);
            window.setTimeout(function() {
                jQuery("#terms-status").slideUp(250);
            }, 3000);

        });
    });
