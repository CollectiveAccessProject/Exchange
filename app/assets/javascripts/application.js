// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require jquery.extendext
//= require doT
//= require query-builder
//= require autocomplete-rails
//= require bootstrap-sprockets
//= require bootstrap-tour
//= require cookie
//= require summernote/summernote-bs4.min
//= require summernote
//= require plugins/media-item/summernote-ext-media-item
//= require summernote-cleaner
//= require query-builder-elasticsearch
//= require jquery.raty
//= require ratyrate
//= require bootstrap-editable
//= require bootstrap-editable-rails
//= require leaflet
//= require leaflet-iiif
//= require moment
//= require bootstrap-datetimepicker
//= require_tree .
//= require will_paginate_infinite
//= require jquery.slidereveal

// Add icontains selector to jQuery - case insensitive text search
$.extend($.expr[":"], {
    "icontains": function(elem, i, match, array) {
        return (elem.textContent || elem.innerText || "").toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
    }
});

function delay(callback, ms) {
  var timer = 0;
  return function() {
    var context = this, args = arguments;
    clearTimeout(timer);
    timer = setTimeout(function () {
      callback.apply(context, args);
    }, ms || 0);
  };
};