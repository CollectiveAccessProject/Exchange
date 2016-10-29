$ ->
  $('#resource_body_text').each ->

    $(this).summernote
      height : 300,
      toolbar : [
        ['style', [ 'bold', 'italic', 'underline', 'clear']],
        ['cleaner',['cleaner']],
        ['font', [ 'fontname', 'strikethrough', 'superscript', 'subscript']],
        ['fontsize', ['fontsize']],
        ['color', ['color']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['height', ['height']],
        ['insert', ['picture', 'link', 'video', 'table', 'hr', 'mediaitem']]
      ],
      buttons : { mediaitem: MediaItemButton },
      callbacks: {
        onInit: ->
          exchangeLoadMediaForSummernote()
      },
      cleaner:{
        notTime:2400,
        action:'both',
        newline:'<p><br></p>',
        notStyle:'position:absolute;bottom:0;left:2px',
        icon:'<i class="fa fa-file-text" aria-hidden="true"></i>'
    }
      
  $('#resource_title, #resource_subtitle').each -> 
    $(this).summernote
      height : 75,
      toolbar : [
        ['style', [ 'bold', 'italic', 'underline', 'clear']],
        ['font', [ 'fontname', 'strikethrough', 'superscript', 'subscript']],
        ['fontsize', ['fontsize']],
        ['color', ['color']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['height', ['height']]
      ]
      
  $('#media_file_caption, #media_file_copyright_notes').each -> 
    $(this).summernote
      height : 75,
      toolbar : [
        ['style', [ 'bold', 'italic', 'underline']],
        ['font', [ 'superscript', 'subscript']]
      ]
