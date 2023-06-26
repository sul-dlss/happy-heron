import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "container", "error", "selectedTemplate", "addItem", "input"]

  open(event) {
    this.searchTarget.focus()
    this.containerTargets.forEach((container) => container.classList.add('keywords-container-open') )
  }

  close(event) {
    this.containerTargets.forEach((container) => container.classList.remove('keywords-container-open') )
  }
}
