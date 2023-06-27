import { Controller } from "@hotwired/stimulus"

// Opens the modal if the url hash is 'help'
export default class extends Controller {
  connect() {
    if (window.location.hash == '#help') {
      var myModalEl = document.getElementById('contactUsModal')
      const modal = new bootstrap.Modal(myModalEl)
      modal.show()
    }
  }
}
