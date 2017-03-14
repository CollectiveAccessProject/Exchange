
jQuery(document).on("ajax:success", "#groupUsers", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#group_user_list").html(data.html);
    }
    jQuery("#group-users-status").slideDown(250);

    jQuery("#group-users-status-message").html((data && data.status && (data.status == 'ok')) ? "Added user to group" : "Could not add user to group: " + data.error);
    window.setTimeout(function() {
        jQuery("#group-users-status").slideUp(250);
    }, 3000);

});

jQuery(document).on("ajax:success", ".setItemsRemove", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#group_user_list").html(data.html);
    }
    jQuery("#group-users-status").slideDown(250);

    jQuery("#group-users-status-message").html((data && data.status && (data.status == 'ok')) ? "Removed user from group" : "Could not remove user from group: " + data.error);
    window.setTimeout(function() {
        jQuery("#group-users-status").slideUp(250);
    }, 3000);

});