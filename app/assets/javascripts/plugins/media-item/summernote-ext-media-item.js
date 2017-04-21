var MediaItemButton = function(context) {
    var ui = $.summernote.ui;

    // create button
    var button = ui.button({
        contents: '<button id="dropdown-media-item-btn" type="button" class="note-btn btn btn-default btn-sm dropdown-toggle" title data-original-title="Media Item" data-toggle="dropdown">' +
        ' Media Item <span class="note-icon-caret"></span></button><div id="dropdown-media" class="dropdown-menu note-check dropdown-media"></div>',
    });
    return button.render();
}


exchangeLoadMediaForSummernote = function() {
    $('#dropdown-media').empty();
    if ($('#resource_media_list .mediaListIcon').length == 0) {
        $('#dropdown-media-item-btn').hide();   // hide media list when there is no linked media
    } else {
        $('#dropdown-media-item-btn').show();
        $('#dropdown-media').append('<div class="container"><div class="row">');
        $('#resource_media_list .mediaListIcon').each(function () {

            media_img = $(this).find('img').attr('src');
            media_iframe = $(this).find('iframe').attr('src');
            media_title = $(this).find('small[class^="slug_"]').html();
	    media_access = $(this).attr('data-access');
            thumb = "";
            if ('undefined' !== typeof(media_img)) {
                thumb = '<img src="' + media_img + '"/>';
            } else if ('undefined' !== typeof(media_iframe)) {
                thumb = '<iframe src="' + media_iframe + '"/>';
            } else {
            	thumb = '<div class="itemIconPadding"><i class="fa fa-image fa-5x"></i></div>';
            }
	    if(media_access == '0'){
	        media_item_attrs = '<div class="col-sm-3 dropdown-media-item"><span class="dropdown-media-hidden">Media is unpublished and cannot be embedded</span>';
	    } else {
 		media_item_attrs = '<div class="col-sm-3 dropdown-media-item">';
  	    }
            $('#dropdown-media').append(media_item_attrs +
                '<div class="media-item-thumb">' + thumb + '</div>' +
                '<span class="media-item-title">' + media_title + '</span>' +
                '</div>'
            );
        });
        $('#dropdown-media').append('</div></div>');
    }
}

jQuery(document).ready(function($) {
    // Create embed on click
    $('.container').on('click', '.dropdown-media-item', function() {
	//Create modal for setting embed options
	var re = /\(([^)]+)\)$/;
	slug = re.exec( $(this).find('.media-item-title').html());
	slug[1].replace('<em>', '').replace('</em>', '')
	function embedModal(slug){
		html = '<div id="embedModal" class="modal fade" tabindex="-1" role="dialog" aria-hidden="true"';
		html += '<div class="modal-dialog">';
		html += '<div class="modal-content">';
		html += '<div class="modal-header">';
		html += '<button type="button" class="close" data-dismiss="modal"><i class="fa fa-times" aria-hidden="true"></i><span class="sr-only">Close</span></button>';
		html += '<h2 class="modal-title">Embed Media Options</h2>';
		html += '</div>';
		html += '<div class="modal-body">';
		html += '<div class="row">';
		html += '<div class="col-sm-12">';
		html += '<form id="embedForm" data-async data-target="#mediaItem" method="GET"><div class="form-group"><h4>Embed Size</h4><div class="radio">';
		html += '<label><input type="radio" name="sizeSetting" id="quarterSetting" value="quarter">Quarter Width</label></div>';
		html += '<div class="radio"><label><input type="radio" name="sizeSetting" id="halfSetting" value="half">Half Width</label></div>';
		html += '<div class="radio"><label><input type="radio" name="sizeSetting" id="fullSetting" value="full">Full Width</label></div>';
		html += '</div>';	
		html += '<div class="form-group"><h4>Display Caption?</h4><div class="radio">';
		html += '<label><input type="radio" name="captionSetting" id="captionYes" value="yes">Yes</label></div>';
		html += '<div class="radio"><label><input type="radio"  name="captionSetting" id="captionNo" value="no">No</label></div>';
		html += '</div>';
		html += '<div class="form-group"><h4>Embed Float</h4>';
		html += '<div class="radio"><label><input type="radio" name="floatSetting" id="floatLeft" value="left">Left</label></div>';
		html += '<div class="radio"><label><input type="radio" name="floatSetting" id="floatRight" value="right">Right</label></div>';
		html += '<div class="radio"><label><input type="radio" name="floatSetting" id="floatNone" value="none">None</label></div>';
		html += '</div>';
		//Clicking the submit button sends the proper item, slug and form data to the embedMedia() function, defined in the _form.hmtl.erb views file
		html += '<div class="form-group"><input type="button" id="embedCreate" class="btn btn-primary" value="Embed Media" onClick="embedMedia(slug);"/></div>';
		html += '</form>';
		html += '</div></div></div></div></div></div>';
		$('body').append(html);
		$('#embedModal').modal();
		$('#embedModal').modal('show');
	}
	embedModal();
    });
});
