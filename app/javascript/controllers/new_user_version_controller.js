import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['versionDescription', 'userVersionYes', 'userVersionNo', 'versionDescriptionYes', 'versionDescriptionNo', 'versionDescriptionError', 'fileSection', 'fileUploadsFieldset']

  connect () {
    if (!this.hasUserVersionYesTarget || !this.hasUserVersionNoTarget) return

    if (this.userVersionYesTarget.checked === true) {
      this.versionDescriptionNoTarget.disabled = true
      this.versionDescriptionNoTarget.value = ''
      this.versionDescriptionYesTarget.required = true
      this.versionDescriptionYesTarget.disabled = false
      this.versionDescriptionYesTarget.value = this.versionDescriptionTarget.value
      // enable the file upload section
      this.fileUploadsFieldsetTarget.disabled = false
      this.fileSectionTarget.style.opacity = 1.0
    }
    if (this.userVersionNoTarget.checked === true) {
      this.versionDescriptionYesTarget.disabled = true
      this.versionDescriptionYesTarget.value = ''
      this.versionDescriptionNoTarget.disabled = false
      this.versionDescriptionNoTarget.required = true
      this.versionDescriptionNoTarget.value = this.versionDescriptionTarget.value
      // disable the file upload section
      this.fileUploadsFieldsetTarget.disabled = true
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
      this.fileUploadsFieldsetTarget.disabled = true
      this.fileSectionTarget.style.opacity = 0.5
    } else if (event.currentTarget === this.userVersionYesTarget) {
      this.fileUploadsFieldsetTarget.disabled = false
      this.fileSectionTarget.style.opacity = 1.0
    }
  }

  validateUserVersionSelection (event) {
    if (this.userVersionYesTarget.checked === false && this.userVersionNoTarget.checked === false) {
      this.showError('Select a version option')
      event.preventDefault()
    }
  }

  showError (err) {
    if (err) {
      this.versionDescriptionErrorTarget.innerHTML = err
      this.versionDescriptionErrorTarget.style.display = 'block'
      const y = this.versionDescriptionErrorTarget.getBoundingClientRect().top
      window.scrollTo({ top: y, behavior: 'smooth' })
    } else {
      this.hideError()
    }
  }

  hideError () {
    this.versionDescriptionErrorTarget.style.display = 'none'
  }
}
