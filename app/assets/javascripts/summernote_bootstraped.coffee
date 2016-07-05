$ ->
  $('[data-provider="summernote"]').each ->

    $(this).summernote
      height : 300,
      toolbar : [
        ['style', [ 'bold', 'italic', 'underline', 'clear']],
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
      }