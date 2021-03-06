// Place all the behaviors and hooks related to the matching controller here.#
// All this logic will automatically be available in application.js.

jQuery(document).ready(function() {
    //
	// Modal AJAX Loads
	//
	jQuery(document).on('click', '.modalOpen', function(event){
		if($(this).parent('moCurrent').length > 0){
			event.stopPropagation();
			event.preventDefault();
			return false;
		}
		var target_link = jQuery(this).attr('data-link-target');
		var target_modal = jQuery(target_link).attr('data-modal-target');
		$('.moCurrent').removeClass('moCurrent');
		$(".moRelated > a[data-link-target*='" + target_link + "']").parent().addClass('moCurrent');
		jQuery(target_link).trigger('click');
	});
	jQuery(document).on('click', '.mediaLoad', function(event){
		var this_id = jQuery(this).attr("data-modal-target");
		if(jQuery(this_id).has('.modal-dialog').length > 0){
			jQuery(this_id).modal('show');
			event.stopPropagation();
			event.preventDefault();
		} else {
			jQuery(this_id).modal('show');
		}
	});
	jQuery('.popoverWrapper').tooltip();
    
    //
    // Slideshow AJAX Loads
    //
    //Generates slide count and position for use above
	var totalItems = jQuery('#resourceCarousel').attr('data-ajax-media');
	var res_id = jQuery('#resourceCarousel').attr('data-ajax-id');
	var loaded_pages = []
	var page_no = 0
	$('.num').html('1/'+totalItems+'');
	$('#resourceCarousel').on('slid.bs.carousel', function() {
		currentIndex = ($('div.active').index() + 1);
		$('.num').html(''+currentIndex+'/'+totalItems+'');
		if(currentIndex % 9 == 0){
			page_no = currentIndex / 9
			if($.inArray(page_no, loaded_pages) == -1){
				loadMoreSlides(res_id, page_no);
				loaded_pages.push(page_no);
			}
		}
	});
	$('#prevSlide').on('click', function(e) {
		
		oldIndex = ($('div.active').index() + 1);
		if(oldIndex == 1){
			e.preventDefault();
			e.stopPropagation();
			load_pages = Math.ceil(totalItems/10);
			for(var i = 1; i < load_pages; i++){
				if($.inArray(i, loaded_pages) == -1){
					loadMoreSlides(res_id, i);
					loaded_pages.push(i);
				}
			}
			setTimeout(function(){ $('#resourceCarousel').carousel('prev'); }, 2500);
		}
		
	});
    //
    // Thumbnail AJAX Loads
    //
    if(jQuery('#thumbnailContainer').length > 0){
		var caption = jQuery('#thumbnailContainer').attr('data-ajax-caption');
		var available_media = jQuery('#thumbnailContainer').attr('data-ajax-media');
		var res_id = jQuery('#thumbnailContainer').attr('data-ajax-id');
		var type = '<%= @resource.settings(:media_formatting).mode.to_s %>';
		var doc_height = $(document).height();
		var scroll_pos = 0;
		var page = 2;
		var timeout = null;
		var pages = available_media / 8;
		if (available_media > 16) {
			$(window).scroll(function(){
				scroll_pos = $(window).scrollTop();
				if(!timeout){
					timeout = setTimeout(function(){
						clearTimeout(timeout);
						timeout = null;
						if(page != false){
							page = infiniteThumbs(res_id, page, pages, caption, doc_height, scroll_pos);
						}
					}, 200);
				}
			});
		}
	}
    
    //
    // Media list drag and drop
    //
    jQuery("#resource_media_list").sortable();
    jQuery(document).on('sortstop', "#resource_media_list", function(e, ui) {
        var resource_id =  jQuery("#resource_media_list").data("resource_id");
        var offset =  jQuery("#resource_media_list").data("offset");
        if (!offset) { offset = 0; }
        var ranks = [];
        jQuery("#resource_media_list .mediaListIcon").each(function(k,m) {
            ranks.push(jQuery(m).data('media_id'));
        });
        
        if (resource_id && (Object.keys(ranks).length > 0)) {
            jQuery.getJSON("/resources/" + resource_id + "/set_media_order", {ranks: ranks, offset: offset}, function(data) {
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
        jQuery(this).find('iframe').attr('src', jQuery(this).find('iframe').attr('src'));
    });
    
    // Clear media editor modal content on clone
    jQuery('#media_editor_modal').on('hide.bs.modal', function(e) {
        jQuery('#media_editor_modal').html('');
    });
    
    // Block add to collection modal from appearing for duration of session
    jQuery('.resource-coll-opt-out').on('click', function(e) {
        window.sessionStorage.setItem("rcoll_optout_" + jQuery(e.currentTarget).data('resource_id'), "1");
    });
    
    // Block add to collection modal from appearing ever again
    jQuery('#res_collection_optout_perm').on('click', function(e){
    	Cookies.set('rcoll_optout_perm_' + jQuery(e.currentTarget).data('resource_id'), true);
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
        e.preventDefault();
        return false;
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
        e.preventDefault();
        return false;
    });

    // AJAX group access control
    jQuery(document).on("ajax:success", "#resourceGroupAccessElements", function(e, data) {
        if(data.status == 'ok') {
            jQuery("#tab_access").html(data.html)
        }
        jQuery("#access-group-status").slideDown(250);

        jQuery("#access-group-status-message").html((data && data.status && (data.status == 'ok')) ? "Added group" : "Could not add group: " + data.error);
        window.setTimeout(function() {
            jQuery("#access-group-status").slideUp(250);
        }, 3000);
        e.preventDefault();
        return false;
    });

    jQuery(document).on("ajax:success", ".resourceGroupAccessRemoveLink", function(e, data) {
        if(data.status == 'ok') {
            jQuery("#tab_access").html(data.html)
        }
        jQuery("#access-group-status").slideDown(250);

        jQuery("#access-group-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed group" : "Could not remove group: " + data.error);
        window.setTimeout(function() {
            jQuery("#access-group-status").slideUp(250);
        }, 3000);
        e.preventDefault();
        return false;
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


//
//
//
    jQuery("#collectionObjectAddToCollection").on('click', function(e) {
        e.preventDefault();

        var add_to_collection_id = jQuery("#collectionObjectAddToCollectionID").val();

        jQuery.post("/resources/" + add_to_collection_id + "/add_child_resources", {"add_child_resource_ids[]": [jQuery("#collectionObjectAddToCollection").data('id')]}, function(data) {

            jQuery("#collectionObjectAdd-status").slideDown(250);
            jQuery("#collectionObjectAdd-status-message").html("Added collection object to collection");
            window.setTimeout(function() {
                jQuery("#collectionObjectAdd-status").slideUp(250);
            }, 3000);

            return true;
        }, 'json');
        return false;
    });

    jQuery("#resourceAddToCollection").on('click', function(e) {
        e.preventDefault();

        var add_to_collection_id = jQuery("#resourceAddToCollectionID").val();

        jQuery.post("/resources/" + add_to_collection_id + "/add_child_resources", {"add_child_resource_ids[]": [jQuery("#resourceAddToCollection").data('id')]}, function(data) {

            jQuery("#resourceAdd-status").slideDown(250);
            jQuery("#resourceAdd-status-message").html("Added resource to collection");
            window.setTimeout(function() {
                jQuery("#resourceAdd-status").slideUp(250);
            }, 3000);

            return true;
        }, 'json');
        return false;
    });

    jQuery("#tab_responses").on('click', '.responseBankLink', function(e) {
        e.preventDefault();
        var url = jQuery(this).attr('href');

        jQuery.post(url, {"show": jQuery(this).data('show')}, function(data) {
            jQuery("#tab_responses").html(data.html);

            return true;
        }, 'json');
        return false;
    });
});


//
// set list drag and drop
//
jQuery("#link_list").sortable();
jQuery(document).on('sortstop', "#link_list", function(e, ui) {
    var resource_id =  jQuery("#link_list").data("resource_id");

    var ranks = [];
    jQuery("#link_list .linkListItem").each(function(k,m) {
        ranks.push(jQuery(m).data('link_id'));
    });

    if (Object.keys(ranks).length > 0) {
        jQuery.getJSON("/resources/" + resource_id + "/set_link_order", {ranks: ranks}, function(data) {
            jQuery("#links-status").slideDown(250);

            jQuery("#links-status-message").html((data && data.status && (data.status == 'ok')) ? "Saved link order" : "Could not save set link order: " + data.error);
            window.setTimeout(function() {
                jQuery("#links-status").slideUp(250);
            }, 3000);
        });
    }
});

//
// link list drag and drop
//
jQuery("#link_list").sortable();
jQuery(document).on('sortstop', "#link_list", function(e, ui) {
    var resource_id =  jQuery("#link_list").data("resource_id");

    var ranks = [];
    jQuery("#link_list .linkListItem").each(function(k,m) {
        ranks.push(jQuery(m).data('link_id'));
    });

    if (Object.keys(ranks).length > 0) {
        jQuery.getJSON("/resources/" + resource_id + "/set_link_order", {ranks: ranks}, function(data) {
            jQuery("#links-status").slideDown(250);

            jQuery("#links-status-message").html((data && data.status && (data.status == 'ok')) ? "Saved link order" : "Could not save set link order: " + data.error);
            window.setTimeout(function() {
                jQuery("#links-status").slideUp(250);
            }, 3000);
        });
    }
});

//
// related resource list drag and drop
//
jQuery("#related_resource_list").sortable();
jQuery(document).on('sortstop', "#related_resource_list", function(e, ui) {
    var resource_id =  jQuery("#related_resource_list").data("resource_id");

    var ranks = [];
    jQuery("#related_resource_list .relatedResourceListItem").each(function(k,m) {
        ranks.push(jQuery(m).data('link_id'));
    });

    if (Object.keys(ranks).length > 0) {
        jQuery.getJSON("/resources/" + resource_id + "/set_related_resource_order", {ranks: ranks}, function(data) {
            jQuery("#related-resources-status").slideDown(250);

            jQuery("#related-resources-status-message").html((data && data.status && (data.status == 'ok')) ? "Saved resource order" : "Could not save set resource order: " + data.error);
            window.setTimeout(function() {
                jQuery("#related-resources-status").slideUp(250);
            }, 3000);
        });
    }
});

//
// Media list paging
jQuery(document).on("ajax:success", ".mediaListPaging", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#resource_media_list").html(data.html)
    }
    return false;
});
// Media list paging
jQuery(document).on("ajax:success", ".thumbnailPaging", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#thumbnailContainer").html(data.html);
    }
    return false;
});
//
// AJAX Load Functions
//
function infiniteThumbs(res_id, page, pages, caption, doc_height, scroll_pos){
	if(page > pages){
		return false;
	} else {
		if (doc_height - $(window).scrollTop() < 750){
			new_page = loadThumbs(res_id, page, caption);
			doc_height = $(document).height();
			return new_page;
		}
	}
	return page;
}
function loadThumbs(res_id, page_no, caption){
	$.ajax({
		url: "/resources/" + res_id + "/load_thumbnails",
		type: "GET",
		dataType: "html",
		data: {
			resource_id: res_id,
			page: page_no,
			caption: caption
		},
		success: function(html) {
			$('#thumbnailContainer').append(html);
		}
	});
	new_page = page_no + 1;
	return new_page;
}
function loadMoreSlides(res_id, pages){
	$.ajax({
		url: "/resources/" + res_id + "/load_slides",
		type: "GET",
		dataType: "html",
		data: {
			resource_id: res_id,
			page: pages,
		},
		success: function(html) {
			$('#carouselFocus').append(html);
		}
	});
}

//
// Quick Search Bar Resizing
//
function resizeBar(left_element, right_element){
	var right_pos = $(right_element).position().left;
	var left_pos = $(left_element).position().left;
	var left_width = $(left_element).width();
	var spacing = (right_pos) - (left_width + left_pos)
	$(left_element).width(spacing + left_width); 
}