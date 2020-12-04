import { Controller } from "stimulus";

export default class extends Controller  {
  static targets = ["container", "error"];

  // Triggered when edit-deposit controller sends an error event
  error(e) {
    if (e.detail === null || e.detail.length == 0) {
      this.containerTarget.classList.remove('is-invalid')
      this.errorTarget.innerHTML = ''
    } else {
      this.containerTarget.classList.add('is-invalid')
      this.errorTarget.innerHTML = e.detail.join(' ')
    }
  }
}
