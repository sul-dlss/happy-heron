import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['frame']

  connect () {
    this.origSource = this.frameTarget.src
    // Dynamically change the help turbo-frame source to show "Request access to another collection" by default.
    this.element.addEventListener('show.bs.modal', event => {
      const button = event.relatedTarget
      if (!button) return
      const showCollections = button.getAttribute('data-bs-showCollections') === 'true'
      if (showCollections) {
        this.frameTarget.src = this.origSource + '?show_collections=true'
      } else {
        this.frameTarget.src = this.origSource
      }
    })
  }
}
