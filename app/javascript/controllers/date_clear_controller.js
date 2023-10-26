import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['year', 'month', 'day', 'approximate', 'error']

  clear () {
    this.clearInput(this.yearTargets)
    this.clearInput(this.monthTargets)
    this.clearInput(this.dayTargets)
    this.clearCheckbox(this.approximateTargets)
    this.clearError(this.errorTargets)
  }

  clearInput (targets) {
    targets.forEach((target) => {
      target.value = ''
      target.classList.remove('is-invalid')
      target.setCustomValidity('')
      target.required = false
      target.disabled = false
    })
  }

  clearCheckbox (targets) {
    targets.forEach((target) => {
      target.checked = false
      target.disabled = false
    })
  }

  clearError (targets) {
    targets.forEach((target) => {
      target.textContent = ''
    })
  }
}
