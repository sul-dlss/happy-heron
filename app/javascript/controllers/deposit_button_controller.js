import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["depositButton", "globusRadioButton"]

  connect() {
    this.updateDepositButtonStatus()
  }

  updateDepositButtonStatus(_event) {
    this.depositButtonTarget.disabled = this.globusRadioButtonTarget.checked
  }
}