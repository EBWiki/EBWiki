# frozen_string_literal: true

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin 'bootstrap', to: 'bootstrap.esm.min.js'
pin '@popperjs/core', to: 'popper.js'
pin 'trix'
pin '@rails/actiontext', to: 'actiontext.esm.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
