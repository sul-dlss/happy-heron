import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["fileUploads", "globusRadioButton", "browserRadioButton"]

  connect() {
    this.updatePanelVisibility()
  }

  updatePanelVisibility(_event) {
    this.fileUploadsTarget.hidden = !this.browserRadioButtonTarget.checked
  }
}
