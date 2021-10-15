import { Controller } from "stimulus"

// This pops up the bootstrap modal that asks a user if they want to continue working on a draft.
export default class extends Controller {
  connect() {
    var myModal = new bootstrap.Modal(this.element, {})
    myModal.show()
  }
}
