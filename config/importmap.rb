# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'

pin 'application', preload: true
pin 'jquery', to: 'jquery.min.js', preload: true
pin 'jquery_ujs', to: 'jquery_ujs.js', preload: true
pin 'bootstrap-sprockets', to: 'bootstrap-sprockets.js'
pin 'moment', to: 'moment.js'
pin 'bootstrap-datetimepicker', to: 'bootstrap-datetimepicker.js'
pin 'pickers', to: 'pickers.js'
pin 'cocoon', to: 'cocoon.js'
pin 'social-share-button', to: 'social-share-button.js'
pin 'select2', to: 'select2.js'
pin 'popover', to: 'popover.js'
pin 'select', to: 'select.js'
pin 'tooltip', to: 'tooltip.js'
