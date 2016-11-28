jQuery(document).on("ajax:success", ".search-next-btn", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#results_" + data.type).html(data.html)
    }

});