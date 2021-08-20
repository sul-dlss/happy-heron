import { Controller } from "stimulus"

// Handles the "Reserve a PURL" button which pops up a form allowing a title to be provided
export default class extends Controller {
  static targets = ["form", "title", "doiSection"]

  connect() {
    this.hideSelectDoi()
  }

  // Sets the form in the modal to use the action in the data-destination attribute
  setCollection(event) {
    event.preventDefault()
    this.formTarget.action = event.target.dataset.destination
  }

  // Shows the select DOI option in the modal
  showSelectDoi(event) {
    event.preventDefault()
    this.doiSectionTarget.hidden = false
    this.doiSectionTarget.querySelector('input[type="hidden"]').disabled = false
  }

  hideSelectDoi() {
    this.doiSectionTarget.hidden = true
    this.doiSectionTarget.querySelector('input[type="hidden"]').disabled = true
  }

  cancel(event) {
    event.preventDefault()
    this.titleTarget.value = ''
    this.hideSelectDoi()
  }
}
