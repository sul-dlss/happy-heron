import { Controller } from "stimulus";

export default class extends Controller  {
  static targets = ["container", "error"];

  // Triggered when edit-collection controller sends an error event
  error(e) {
    this.containerTarget.classList.add('is-invalid')
    this.errorTarget.innerHTML = e.detail.join(' ')
  }
}
