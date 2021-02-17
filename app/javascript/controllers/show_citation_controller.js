import { Controller } from "stimulus"

export default class extends Controller {
  static values = {
    citation: String,
    header: String,
    target: String,
  }

  setContent() {
    const modal = document.querySelector(this.targetValue)
    modal.querySelector('h5').textContent = `${this.headerValue} citation`
    modal.querySelector('.modal-body').textContent = this.citationValue
  }
}
