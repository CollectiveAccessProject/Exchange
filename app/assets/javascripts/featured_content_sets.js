
jQuery(document).on("ajax:success", "#setItems", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#set_items").html(data.html)
    }
    jQuery("#set-items-status").slideDown(250);

    jQuery("#set-items-status-message").html((data && data.status && (data.status == 'ok')) ? "Added resource to set" : "Could not add resource to set: " + data.error);
    window.setTimeout(function() {
        jQuery("#set-items-status").slideUp(250);
    }, 3000);

});

jQuery(document).on("ajax:success", ".setItemsRemove", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#set_items").html(data.html)
    }
    jQuery("#set-items-status").slideDown(250);

    jQuery("#set-items-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed resource from set" : "Could not remove resource from set: " + data.error);
    window.setTimeout(function() {
        jQuery("#set-items-status").slideUp(250);
    }, 3000);

});

//
// item list drag and drop
//
jQuery("#set_contents_list").sortable();
jQuery(document).on('sortstop', "#set_contents_list", function(e, ui) {
    var set_id =  jQuery("#set_contents_list .setItem").data("featured_content_set_id");
    var ranks = [];
    jQuery("#set_contents_list .setItem").each(function(k,m) {
        ranks.push(jQuery(m).data('resource_id'));
    });
console.log("XX", ranks, set_id);
    if (set_id && (Object.keys(ranks).length > 0)) {
        jQuery.getJSON("/featured_content_sets/" + set_id + "/set_item_order", {ranks: ranks}, function(data) {
            jQuery("#set-items-status").slideDown(250);

            jQuery("#set-items-status-message").html((data && data.status && (data.status == 'ok')) ? "Saved item order" : "Could not save item sort order: " + data.error);
            window.setTimeout(function() {
                jQuery("#set-items-status").slideUp(250);
            }, 3000);
        });
    }
});