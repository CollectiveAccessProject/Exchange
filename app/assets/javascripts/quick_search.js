jQuery(document).on("ajax:success", ".search-next-btn", function(e, data) {
    if(data.status == 'ok') {
        jQuery("#results_" + data.type).html(data.html)
    }

});


function getDateExprFromFilterUI(prefix, f, i) {
    if (!f) { f = 'date_last_updated'; }
    if (!i) { i = 'updated_at'; }
    var mode = jQuery("#" + prefix + "_" + f + "_mode").val();  
    var date_expr = null;

    if (mode == 'between') {
        var min = jQuery("#" + prefix + "_" + f + "_min").val(); 
        var max = jQuery("#" + prefix + "_" + f + "_max").val(); 
        if (min && max) {
            date_expr = i + ":[" + min + " TO " + max + "]";
        }
    } else {
        var date = jQuery("#" + prefix + "_" + f + "_date").val(); 
        if (date) {
            if (mode == 'in') {
                date_expr = i + ":[" + date + " TO " + date + "]";
            } else if(mode == 'before') {
                date_expr = i + ":[1900-01-01 TO " + date + "]";
            } else if(mode == 'after') {
                date_expr = i + ":[" + date + " TO 2100-01-01]";
            }
        }
    }
    return date_expr;
}

function updateDateFilterUI(prefix, f) {
    if (!f) { f = 'date_last_updated'; }
    var mode = jQuery("#" + prefix + "_" + f + "_mode").val();  
            
    if (mode == 'between') {
        jQuery("#" + prefix + "_" + f + "_range, #" + prefix + "_" + f + "_min, #" + prefix + "_" + f + "_max").show().attr('disabled', false);
        jQuery("#" + prefix + "_" + f + "_date").hide().attr('disabled', true);
    } else {
        jQuery("#" + prefix + "_" + f + "_range, #" + prefix + "_" + f + "_min, #" + prefix + "_" + f + "_max").hide().attr('disabled', true);
        jQuery("#" + prefix + "_" + f + "_date").show().attr('disabled', false);
    }
}