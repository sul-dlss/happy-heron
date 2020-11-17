import { Controller } from "stimulus"

export default class extends Controller {
  // static targets = ["search", "container", "error", "selectedTemplate", "addItem"]
  static targets = ["error", "container"]

  // Triggered when edit-deposit controller sends an error event
  error(e) {
    this.containerTarget.classList.add('is-invalid')
    this.errorTarget.innerHTML = e.detail.join(' ')
  }
}
