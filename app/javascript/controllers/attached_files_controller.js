import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['userVersionNo', 'userVersionYes', 'fileDescription', 'removeFileButton', 'hideFileCheckbox', 'dropzoneContainer']

  connect () {
    if (!this.hasUserVersionYesTarget || !this.hasUserVersionNoTarget) return

    if (this.userVersionYesTarget.checked === true) {
      this.fileDescriptionTargets.readOnly = false
      this.removeFileButtonTargets.disabled = false
      this.hideFileCheckboxTargets.disabled = false
    } else if (this.userVersionNoTarget.checked === true) {
      this.dropzoneContainerTarget.hidden = true
      this.fileDescriptionTargets.map(attachedFile => attachedFile.readOnly = true)
      this.removeFileButtonTargets.map(removeButton => removeButton.disabled = true)
      this.hideFileCheckboxTargets.map(hideFile => hideFile.disabled = true)
    }
  } 

  attachedFilesEditability (event) {
    if (event.currentTarget === this.userVersionNoTarget) {
    // if No target is checked, disable attached file form fields
      this.dropzoneContainerTarget.hidden = true
      this.fileDescriptionTargets.map(attachedFile => attachedFile.readOnly = true)
      this.removeFileButtonTargets.map(removeButton => removeButton.disabled = true)
      this.hideFileCheckboxTargets.map(hideFile => hideFile.disabled = true)
    } else if (event.currentTarget === this.userVersionYesTarget) {
      // if Yes target is checked, enable the attached files buttons and dropzone
      this.dropzoneContainerTarget.hidden = false
      this.fileDescriptionTargets.map(attachedFile => attachedFile.readOnly = false)
      this.removeFileButtonTargets.map(removeButton => removeButton.disabled = false)
      this.hideFileCheckboxTargets.map(hideFile => hideFile.disabled = false)
    }
  }
}
