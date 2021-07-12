import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["uri", "input"]

  connect() {
    this.change()
  }

  change() {
    if(this.uriTarget.value) {
      this.inputTarget.readOnly = true
    }
  }
}
