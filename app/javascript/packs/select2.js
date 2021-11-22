import $ from 'jquery';

$(document).on('turbolinks:load', function() {
  $('select').select2({
  });
});
