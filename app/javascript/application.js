import '@hotwired/turbo-rails'
import 'controllers'
import * as bootstrap from 'bootstrap'
import 'trix'
import '@rails/actiontext'

window.bootstrap = bootstrap

const initializePopovers = () => {
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach((element) => {
    bootstrap.Popover.getOrCreateInstance(element)
  })
}

document.addEventListener('turbo:load', initializePopovers)
document.addEventListener('turbo:frame-load', initializePopovers)
