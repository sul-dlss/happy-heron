// Entry point for the build script in your package.json
require("@rails/ujs").start()
require("@rails/activestorage").start()
require("./channels")
import '@github/time-elements'

window.bootstrap = require("bootstrap") // Required for contact_us_controller
import './controllers'

import '@hotwired/turbo-rails'
import '@fortawesome/fontawesome-free/js/all.js'
import 'simple-datatables'

require('./modules/validate-forms')

window.addEventListener("turbo:before-cache", function() {
    // Close modal window
    document.querySelectorAll('div.modal').forEach(function (elem) {
        bootstrap.Modal.getInstance(elem)?.hide()
    })
})
