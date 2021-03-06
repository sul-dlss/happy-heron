import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["form", "title"]

  // Sets the form in the popup to use the action in the data-destination attribute
  set_collection(event) {
    event.preventDefault()
    this.formTarget.action = event.target.dataset.destination
  }

  cancel(event) {
    event.preventDefault()
    this.titleTarget.value = ''
  }
}
