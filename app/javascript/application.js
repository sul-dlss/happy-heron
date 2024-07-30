// Entry point for the build script in your package.json
import '@github/relative-time-element'
import './controllers'
import '@hotwired/turbo-rails'
import '@fortawesome/fontawesome-free/js/fontawesome'
import '@fortawesome/fontawesome-free/js/regular'
import '@fortawesome/fontawesome-free/js/solid'
import 'simple-datatables'
import bootstrap from 'bootstrap/dist/js/bootstrap'

require('@rails/ujs').start()
require('@rails/activestorage').start()
require('./channels')
require('./modules/validate-forms')

window.addEventListener('turbo:before-cache', () => {
  // Close modal window
  document.querySelectorAll('div.modal').forEach(function (elem) {
    bootstrap.Modal.getInstance(elem)?.hide()
  })
})
