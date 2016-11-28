jQuery(document).on("ajax:success", ".loadSet", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#set_contents").html(data.html)
    }

});