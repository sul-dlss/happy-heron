import { Controller } from '@hotwired/stimulus'

// Sets the form when the user is selecting a work type and subtypes when they
// would like to start a new deposit.
// This must be wrapped around the WorkTypeModalComponent because that renders
// all of the targets that this script expects.
export default class extends Controller {
  static targets = [
    'form'
  ]

  // Sets the form in the popup to use the action in the data-destination attribute
  setCollection (event) {
    event.preventDefault()
    // Use currentTarget (instead of target) because it gets the element with the Stimulus data attributes. Useful
    // when the data attributes and Stimulus action are defined on an element that wraps other elements. E.g. when an
    // a tag wraps a span tag with an icon (with the Stimulus data on the a tag), if the user clicks the linked span
    // icon, target is the span and currentTarget is the anchor.
    this.formTarget.action = event.currentTarget.dataset.destination
    if (event.currentTarget.dataset.formMethod) {
      this.formTarget.method = event.currentTarget.dataset.formMethod
    } else {
      // reset to default in case prior caller popped used model with non-default
      this.formTarget.method = 'get'
    }
  }
}
