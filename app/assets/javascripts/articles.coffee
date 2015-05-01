# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  agencies = $('#article_agency_id').html()
  $('#article_state_id').change ->
    state = $('#article_state_id :selected').text()
    options = $(agencies).filter("optgroup[label='#{state}']").html()
    if options
      $('#article_agency_id').html(options)
    else
      $('#article_agency_id').empty()