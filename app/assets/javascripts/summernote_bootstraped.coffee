$ ->
  $('#resource_body_text, #featured_content_set_body_text').each ->
    $(this).summernote
      height : 300,
      toolbar : [
        ['style', [ 'bold', 'italic', 'underline', 'clear']],
        ['cleaner',['cleaner', 'codeview']],
        ['font', [ 'fontname', 'strikethrough', 'superscript', 'subscript']],
        ['fontsize', ['fontsize']],
        ['color', ['color']],
        ['para', ['ul', 'ol', 'paragraph']],
        ['height', ['height']],
        ['insert', ['link', 'table', 'hr', 'mediaitem']],
      ],
      buttons : { mediaitem: MediaItemButton },
      callbacks: {
        onInit: ->
          exchangeLoadMediaForSummernote()
        onPaste: ->
          setTimeout ( ->
            console.log('hello')
          ), 5
      },
      cleaner:{
        notTime:2400,
        action:'button',
        newline:'<br/>',
        notStyle:'position:absolute;bottom:0;left:2px',
        icon:'<i class="fa fa-file-text" aria-hidden="true"></i>'
      }
    
      
  $('#media_file_caption, #media_file_copyright_notes, #resource_copyright_notes, #resource_title, #resource_subtitle, #featured_content_set_title, #featured_content_set_subtitle').each -> 
    $(this).summernote
      height : 75,
      toolbar : [
        ['style', [ 'bold', 'italic', 'underline', 'codeview']],
        ['font', [ 'superscript', 'subscript']],
      ]

  $('.mediaLoad').bind('ajax:success', ((e) ->
    $('#media_file_caption, #media_file_copyright_notes').each ->  
      $(this).summernote
        height : 75,
        toolbar : [
          ['style', [ 'bold', 'italic', 'underline', 'codeview']],
          ['font', [ 'superscript', 'subscript']],
        ]
  ))
