import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["confirm", "submit"]

  connect() {
    this.change()
  }

  change() {
    this.submitTarget.disabled = !this.confirmTarget.checked
  }
}
