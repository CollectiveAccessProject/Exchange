var MediaItemButton = function(context) { 
  var ui = $.summernote.ui;

  // create button
  var button = ui.button({
    contents: '<button type="button" class="note-btn btn btn-default btn-sm dropdown-toggle" title data-original-title="Media Item" data-toggle="dropdown">' +
    ' Media Item <span class="note-icon-caret"></span></button><div id="dropdown-media" class="dropdown-menu note-check dropdown-media"></div>',
   });
    console.log("create button");
  return button.render();
}


jQuery(document).ready(function($) {

  exchangeLoadMediaForSummernote = function() {
      $('#dropdown-media').empty();
    $('#resource_media_list .mediaListIcon').each(function() {

       media_img    = $(this).find('img').attr('src');
       media_iframe = $(this).find('iframe').attr('src');
       media_title  = $(this).find('small[class^="slug_"]').html();  

       thumb = "";
       if ('undefined' !== typeof(media_img)) {
           thumb = '<img src="' + media_img + '"/>';
       } else if('undefined' !== typeof(media_iframe))  {
           thumb = '<iframe src="' + media_iframe + '"/>';
       }

       $('#dropdown-media').append('<div class="dropdown-media-item" style="color: #000; padding: 2%;">' +
         '<div class="media-item-thumb">' + thumb + '</div>' +
         '<span class="media-item-title">' + media_title + '</span>' + 
         '</div>'
       );
        console.log($('#dropdown-media'), $('#dropdown-media').html());
    });

  }

  // Create embed on click
  $('.container').on('click', '.dropdown-media-item', function() {

    var re = /\(([^)]+)\)/;
    slug = re.exec( $(this).find('.media-item-title').html().replace("<em>", "").replace("</em>", "") );
    embed = '<media ' + slug[1] + ' version="thumbnail" float="left">';

    $('#resource_body_text').summernote('insertText', embed);

  });


});