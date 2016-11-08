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
        $('#resource_media_list .mediaListIcon').each(function () {

            media_img = $(this).find('img').attr('src');
            media_iframe = $(this).find('iframe').attr('src');
            media_title = $(this).find('small[class^="slug_"]').html();

            thumb = "";
            if ('undefined' !== typeof(media_img)) {
                thumb = '<img src="' + media_img + '"/>';
            } else if ('undefined' !== typeof(media_iframe)) {
                thumb = '<iframe src="' + media_iframe + '"/>';
            }

            $('#dropdown-media').append('<div class="dropdown-media-item" style="color: #000; padding: 2%;">' +
                '<div class="media-item-thumb">' + thumb + '</div>' +
                '<span class="media-item-title">' + media_title + '</span>' +
                '</div>'
            );
        });
    }
}

jQuery(document).ready(function($) {
    // Create embed on click
    $('.container').on('click', '.dropdown-media-item', function() {
	//Create modal for setting embed options
	var re = /\(([^)]+)\)/;
	slug = re.exec( $(this).find('.media-item-title').html().replace("<em>", "").replace("</em>", "") );
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
		//Clicking the submit button sends the propera item slug and form data to the embedMeida() function, definited in the _form.hmtl.erb views file
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
