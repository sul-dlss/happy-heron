import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["depositButton", "globusRadioButton", "globusCheckbox", "globusMessage", ]

  connect() {
    this.updateDepositButtonStatus()
  }

  updateDepositButtonStatus(_event) {
    this.globusMessageTarget.hidden = !this.globusRadioButtonTarget.checked || (this.hasGlobusCheckboxTarget && this.globusCheckboxTarget.checked)
    this.depositButtonTarget.disabled = this.globusRadioButtonTarget.checked && (!this.hasGlobusCheckboxTarget || !this.globusCheckboxTarget.checked)
  }
}
