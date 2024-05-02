import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['versionDescription', 'userVersionYes', 'userVersionNo', 'versionDescriptionYes', 'versionDescriptionNo', 'versionDescriptionError']

  connect () {
    this.versionDescriptionYesTarget.disabled = true
    this.versionDescriptionNoTarget.disabled = true
    this.versionDescriptionYesTarget.value = this.versionDescriptionTarget.value
    this.versionDescriptionNoTarget.value = this.versionDescriptionTarget.value
  }

  displayVersionDescription (event) {
    // Version description input enabled when radio selected
    if (event.currentTarget === this.userVersionYesTarget) {
      this.versionDescriptionYesTarget.disabled = false
      this.versionDescriptionNoTarget.disabled = true
    } else if (event.currentTarget === this.userVersionNoTarget) {
      this.versionDescriptionNoTarget.disabled = false
      this.versionDescriptionYesTarget.disabled = true
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
