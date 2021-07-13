// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")
import '@popperjs/core'
import '@github/time-elements'

window.bootstrap = require("bootstrap") // Required for contact_us_controller
import 'controllers'

import '@hotwired/turbo-rails'
require.context('../images', true)
import './application.scss'
import '@fortawesome/fontawesome-free/css/all.css'
import '@fortawesome/fontawesome-free/js/all.js'
import 'simple-datatables'

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

require('modules/validate-forms')

window.addEventListener("turbolinks:before-cache", function() {
    // Close modal window
    document.querySelectorAll('div.modal').forEach(function (elem) {
        bootstrap.Modal.getInstance(elem).hide()
    })
})