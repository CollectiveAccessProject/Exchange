var MediaItemButton = function(context) { 
  var ui = $.summernote.ui;

  // create button
  var button = ui.button({
    contents: '<button type="button" class="note-btn btn btn-default btn-sm dropdown-toggle" title data-original-title="Media Item" data-toggle="dropdown">' +
    ' Media Item <span class="note-icon-caret"></span></button><div id="dropdown-media" class="dropdown-menu note-check dropdown-media"></div>',
   });

  return button.render();
}


jQuery(document).ready(function($) {

  $('.summernote').on('summernote.init', function() {

    console.log('... now? ');
    console.log( $('#dropdown-media') );

    $('#resource_media_list .mediaListIcon').each(function() {

      media_img   = $(this).find('img').attr('src');
      media_ifram = $(this).find('iframe').attr('src');
      media_title = $(this).find('small[class^="slug_"]').html();  

      $('#dropdown-media').append('<div class="dropdown-media-item" style="color: #000; padding: 2%;">' + media_title + '</div>');
    })
  });

});

