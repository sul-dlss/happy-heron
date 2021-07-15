import { Controller } from "stimulus"

// Handles the "Reserve a PURL" button which pops up a form allowing a title to be provided
export default class extends Controller {
  static targets = ["form", "title"]

  // Sets the form in the popup to use the action in the data-destination attribute
  setCollection(event) {
    event.preventDefault()
    this.formTarget.action = event.target.dataset.destination
  }

  cancel(event) {
    event.preventDefault()
    this.titleTarget.value = ''
  }
}
