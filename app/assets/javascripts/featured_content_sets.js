
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