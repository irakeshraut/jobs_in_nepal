import $ from 'jquery';

// This hack is required so select2 won't render twice
document.addEventListener('turbolinks:before-cache', function() {   
  $('.select2-hidden-accessible').select2('destroy'); 
});

$(document).on('turbolinks:load', function() {
  $('select').select2({
  });
});
