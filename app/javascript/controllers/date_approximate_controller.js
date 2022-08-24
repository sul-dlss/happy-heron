import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["day", "approximate"]

  static values = {
    enabled: Boolean
  }

  connect() {
    if(this.enabledValue) this.change()
  }

  change() {
    this.approximateTarget.disabled = this.dayTarget.value != ""
    this.dayTarget.disabled = this.approximateTarget.checked
  }
}
