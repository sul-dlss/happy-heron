import bootstrap from 'bootstrap/dist/js/bootstrap'
import { Controller } from '@hotwired/stimulus'

// This pops up the bootstrap modal that asks a user if they want to continue working on a draft.
export default class extends Controller {
  connect () {
    const myModal = new bootstrap.Modal(this.element, {})
    myModal.show()
  }
}
