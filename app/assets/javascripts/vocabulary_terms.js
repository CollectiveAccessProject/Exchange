jQuery(document).on("ajax:success", "#setItems", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#set_items").html(data.html);
    }
    jQuery("#set-items-status").slideDown(250);

    jQuery("#set-items-status-message").html((data && data.status && (data.status == 'ok')) ? "Added synonym" : "Could not add synonym: " + data.error);
    window.setTimeout(function() {
        jQuery("#set-items-status").slideUp(250);
    }, 3000);

});

jQuery(document).on("ajax:success", ".setItemsRemove", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#set_items").html(data.html);
    }
    jQuery("#set-items-status").slideDown(250);

    jQuery("#set-items-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed synonym" : "Could not remove synonym: " + data.error);
    window.setTimeout(function() {
        jQuery("#set-items-status").slideUp(250);
    }, 3000);

});

jQuery(document).on("ajax:success", "#editSetItemFormElements", function(e, data) {
    jQuery('.modal').modal('hide');
    if(data.status == 'ok') {
        jQuery("#set_items").html(data.html);

    }
    jQuery("#set-items-status").slideDown(250);

    jQuery("#set-items-status-message").html((data && data.status && (data.status == 'ok')) ? "Edited synonym" : "Could not edit synonym: " + data.error);
    window.setTimeout(function() {
        jQuery("#set-items-status").slideUp(250);
    }, 3000);

    e.preventDefault();

});
