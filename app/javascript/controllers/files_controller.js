import { Controller } from "stimulus";

export default class extends Controller  {
  static targets = ["container", "error"];

  // Triggered when edit-deposit controller sends an error event
  error(e) {
    if (e.detail === null || e.detail.length == 0) {
      this.clearErrors()
    } else {
      this.setErrors(e.detail)
    }
  }

  clearErrors() {
    this.containerTarget.classList.remove('is-invalid')
    this.errorTarget.innerHTML = ''
  }

  setErrors(detail) {
    this.containerTarget.classList.add('is-invalid')
    this.errorTarget.innerHTML = detail.join(' ')
  }
}
