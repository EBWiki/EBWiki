// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require gmaps/google
//= require jquery
//= require ahoy
//= require jquery.turbolinks
//= require jquery_ujs
//= require bootstrap-sprockets
//= require moment
//= require bootstrap-datetimepicker
//= require pickers
//= require cocoon
//= require turbolinks
//= require social-share-button
//= require underscore
//= require select2
//= require_tree .
//= require ckeditor/init
//= require fullcalendar

$('#calendar').fullCalendar({});

$(document).ready(function(){
 $('.form-links .nested-fields').map((index, link) => {
   const urlInput = $('#case_links_attributes_' + index + '_url');
   $(urlInput).on("change paste keyup blur focus", function() {
     let suggestedTitle = '';
     const titleInput = $('#case_links_attributes_' + index + '_title');
     const titleInputVal = $(titleInput).val();

     if ($(this).val().length) {
       suggestedTitle = get_hostname($(this).val())
     } else {
       suggestedTitle = '';
     }
     if (!titleInputVal.length || !$(this).val().length) {
       console.log('We have empty title, and suggested title is ', suggestedTitle);
       $(titleInput).val(suggestedTitle.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();}));
     }
   });

   function get_hostname(url) {
     const a = document.createElement('a');
     a.href = url;
     return a.hostname.split('.')[0];
   };
 });
});