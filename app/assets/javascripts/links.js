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