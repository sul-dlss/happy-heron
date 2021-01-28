import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["immediate", "year", "month", "day"]

  connect() {
    if (this.immediateTarget.checked)
      this.immediate()
    else
      this.embargo()
  }

  // Disable the embargo date components
  immediate() {
    this.yearTarget.disabled = true
    this.monthTarget.disabled = true
    this.dayTarget.disabled = true
  }

  // Enable the embargo date components
  embargo() {
    this.yearTarget.disabled = false
    this.monthTarget.disabled = false
    this.dayTarget.disabled = false
  }
}
