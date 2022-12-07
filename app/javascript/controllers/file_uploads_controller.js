import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["fileUploads", "browserRadioButton", "globusRadioButton", "zipUpload", "zipRadioButton"]

  connect() {
    this.updatePanelVisibility()
  }

  updatePanelVisibility(_event) {
    this.fileUploadsTarget.hidden = !this.browserRadioButtonTarget.checked
    this.zipUploadTarget.hidden = !this.zipRadioButtonTarget.checked
  }
}
