import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['fileUploads', 'browserRadioButton', 'globusRadioButton', 'zipUpload', 'zipRadioButton', 'globusUpload']

  connect () {
    this.updatePanelVisibility()
  }

  updatePanelVisibility () {
    // The fileUploadsTarget is undefined if the user has already uploaded more than Settings.max_uploaded_files.
    if (this.hasFileUploadsTarget) {
      this.fileUploadsTarget.hidden = !this.browserRadioButtonTarget.checked
    }
    this.zipUploadTarget.hidden = !this.zipRadioButtonTarget.checked
    this.globusUploadTarget.hidden = !this.globusRadioButtonTarget.checked
  }
}
