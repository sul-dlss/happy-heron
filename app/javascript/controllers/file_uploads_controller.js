import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileUploads", "browserRadioButton", "globusRadioButton", "zipUpload", "zipRadioButton", "globusUpload"]

  connect() {
    this.updatePanelVisibility()
  }

  updatePanelVisibility() {
    this.fileUploadsTarget.hidden = !this.browserRadioButtonTarget.checked
    this.zipUploadTarget.hidden = !this.zipRadioButtonTarget.checked
    this.globusUploadTarget.hidden = !this.globusRadioButtonTarget.checked
  }
}
