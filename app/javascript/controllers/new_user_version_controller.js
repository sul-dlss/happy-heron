import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['versionDescription', 'userVersionYes', 'userVersionNo', 'versionDescriptionYes', 'versionDescriptionNo', 'versionDescriptionError',
    'fileSection', 'browserRadioButton', 'zipRadioButton', 'globusRadioButton', 'chooseFilesButton', 'fileDescription', 'removeFileButton', 'hideFileCheckbox', 'dropzoneContainer']

  connect () {
    if (!this.hasUserVersionYesTarget || !this.hasUserVersionNoTarget) return

    if (this.userVersionYesTarget.checked === true) {
      this.versionDescriptionNoTarget.disabled = true
      this.versionDescriptionNoTarget.value = ''
      this.versionDescriptionYesTarget.required = true
      this.versionDescriptionYesTarget.disabled = false
      this.versionDescriptionYesTarget.value = this.versionDescriptionTarget.value
      this.fileDescriptionTargets.readOnly = false
      this.removeFileButtonTargets.disabled = false
      this.hideFileCheckboxTargets.disabled = false
    }
    if (this.userVersionNoTarget.checked === true) {
      this.versionDescriptionYesTarget.disabled = true
      this.versionDescriptionYesTarget.value = ''
      this.versionDescriptionNoTarget.disabled = false
      this.versionDescriptionNoTarget.required = true
      this.versionDescriptionNoTarget.value = this.versionDescriptionTarget.value
      this.dropzoneContainerTarget.hidden = true
      this.fileDescriptionTargets.map(attachedFile => (attachedFile.readOnly = true))
      this.removeFileButtonTargets.map(removeButton => (removeButton.disabled = true))
      this.hideFileCheckboxTargets.map(hideFile => (hideFile.disabled = true))
      this.fileSectionTarget.style.opacity = 0.5
    }
  }

  displayVersionDescription (event) {
    // Version description input enabled when radio selected
    if (event.currentTarget === this.userVersionYesTarget) {
      this.versionDescriptionYesTarget.disabled = false
      this.versionDescriptionYesTarget.required = true
      this.versionDescriptionNoTarget.disabled = true
      this.versionDescriptionNoTarget.required = false
    } else if (event.currentTarget === this.userVersionNoTarget) {
      this.versionDescriptionNoTarget.disabled = false
      this.versionDescriptionNoTarget.required = true
      this.versionDescriptionYesTarget.disabled = true
      this.versionDescriptionYesTarget.required = false
    }
  }

  disableFileUploads (event) {
    if (event.currentTarget === this.userVersionNoTarget) {
      // create appearance of disabled file upload section while leaving files attached and able to be submitted with form
      this.browserRadioButtonTarget.hidden = true
      this.zipRadioButtonTarget.disabled = true
      this.globusRadioButtonTarget.disabled = true
      this.chooseFilesButtonTarget.disabled = true
      this.fileSectionTarget.style.opacity = 0.5
      // make attached file form fields read-only and disable buttons
      this.dropzoneContainerTarget.hidden = true
      this.fileDescriptionTargets.map(attachedFile => (attachedFile.readOnly = true))
      this.removeFileButtonTargets.map(removeButton => (removeButton.disabled = true))
      this.hideFileCheckboxTargets.map(hideFile => (hideFile.disabled = true))
    } else if (event.currentTarget === this.userVersionYesTarget) {
      // enable upload radio buttons
      this.browserRadioButtonTarget.hidden = false
      this.zipRadioButtonTarget.disabled = false
      this.globusRadioButtonTarget.disabled = false
      this.chooseFilesButtonTarget.disabled = false
      this.fileSectionTarget.style.opacity = 1.0
      // enable the attached files buttons and dropzone
      this.dropzoneContainerTarget.hidden = false
      this.fileDescriptionTargets.map(attachedFile => (attachedFile.readOnly = false))
      this.removeFileButtonTargets.map(removeButton => (removeButton.disabled = false))
      this.hideFileCheckboxTargets.map(hideFile => (hideFile.disabled = false))
    }
  }

  validateUserVersionSelection (event) {
    if (this.userVersionYesTarget.checked === false && this.userVersionNoTarget.checked === false) {
      this.showError('Please select a version option')
      event.preventDefault()
    }
    if (this.userVersionYesTarget.checked === true && this.versionDescriptionYesTarget.value === '') {
      this.showError('Please enter a version description')
      event.preventDefault()
    }
    if (this.userVersionNoTarget.checked === true && this.versionDescriptionNoTarget.value === '') {
      this.showError('Please enter a version description')
      event.preventDefault()
    }
  }

  showError (err) {
    if (err) {
      this.versionDescriptionErrorTarget.innerHTML = err
      this.versionDescriptionErrorTarget.style.display = 'block'
    } else {
      this.hideError()
    }
  }

  hideError () {
    this.versionDescriptionErrorTarget.style.display = 'none'
  }
}
