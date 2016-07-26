/**
 * Created by seth on 7/24/16.
 */
jQuery(document).ready(function() {
   jQuery("#dashboardSearch").on("keyup", function(e) {
       var s = jQuery("#dashboardSearch").val().trim();
       return _dashboard_search(s, '#dashboardResourceList .dbUnit');
   });

    jQuery("#favoritesSearch").on("keyup", function(e) {
        var s = jQuery("#favoritesSearch").val().trim();
        return _dashboard_search(s, '#favoritesList .dbFavoriteContainer');
    });

    function _dashboard_search(search, selector) {
        if (search.length == 0) {
            jQuery(selector).fadeIn(250);
            return true;
        }
        //jQuery(selector).fadeOut(250);
        jQuery(selector).not(":icontains('" + search + "')").fadeOut(250);
        jQuery(selector + ":icontains('" + search + "')").fadeIn(250);
    }

    jQuery(document).on("ajax:success", ".dbFavoriteDeleteControl", function (e, data) {
        if (data.status == 'ok') {
            var favorite_id = jQuery(this).data('id');
            jQuery("#dbFavorite" + favorite_id).remove();
        }
    });
});