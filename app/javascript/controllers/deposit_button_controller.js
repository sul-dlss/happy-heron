import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["depositButton", "globusRadioButton", "globusMessage"]

  connect() {
    this.updateDepositButtonStatus()
  }

  updateDepositButtonStatus(_event) {
    this.depositButtonTarget.disabled = this.globusRadioButtonTarget.checked
    this.globusMessageTarget.hidden = !this.globusRadioButtonTarget.checked
  }
}
