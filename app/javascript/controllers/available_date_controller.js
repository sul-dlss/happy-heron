import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['year', 'month', 'day', 'error']

  validate () {
    this.errors = {}
    this.dateInFuture()
    this.allPartsPresent()
    this.validDate()
    this.displayErrors()
  }

  showError (err) {
    if (err) {
      this.errorTarget.innerHTML = err
      this.errorTarget.style.display = 'block'
    } else {
      this.hideError()
    }
  }

  hideError () {
    this.errorTarget.style.display = 'none'
  }

  clearError () {
    this.errors = {}
    this.displayErrors()
  }

  displayErrors () {
    if (this.errors.year) {
      this.yearTarget.classList.add('is-invalid')
      this.yearTarget.setCustomValidity(this.errors.year)
    } else {
      this.yearTarget.classList.remove('is-invalid')
      this.yearTarget.setCustomValidity('')
    }

    if (this.errors.month) {
      this.monthTarget.classList.add('is-invalid')
      this.monthTarget.setCustomValidity(this.errors.month)
    } else {
      this.monthTarget.classList.remove('is-invalid')
      this.monthTarget.setCustomValidity('')
    }

    if (this.errors.day) {
      this.dayTarget.classList.add('is-invalid')
      this.dayTarget.setCustomValidity(this.errors.day)
    } else {
      this.dayTarget.classList.remove('is-invalid')
      this.dayTarget.setCustomValidity('')
    }

    this.showError(this.errors.year || this.errors.month || this.errors.day)
  }

  dateInFuture () {
    const currentTime = new Date()
    const currentMonth = currentTime.getMonth() + 1
    const currentDay = currentTime.getDate()
    const currentYear = currentTime.getFullYear()
    const day = this.dayTarget.value
    const month = this.monthTarget.value
    const year = this.yearTarget.value

    if (year < currentYear) {
      this.errors.year = 'must be in the future'
    } else if (year === currentYear) {
      if (month < currentMonth) {
        this.errors.month = 'must be in the future'
      } else if (month === currentMonth && day < currentDay) {
        this.errors.day = 'must be in the future'
      }
    }
  }

  // Validate that all parts are provided
  allPartsPresent () {
    const day = this.dayTarget.value
    const month = this.monthTarget.value
    const year = this.yearTarget.value

    if (!year) {
      this.errors.year = 'all parts must be provided'
    } else if (!month) {
      this.errors.month = 'all parts must be provided'
    } else if (!day) {
      this.errors.day = 'all parts must be provided'
    }
  }

  // Validate that the day selected is in the month
  validDate () {
    const day = this.dayTarget.value
    const month = this.monthTarget.value
    const year = this.yearTarget.value

    if (isNaN(new Date(`${year}-${month}-${day}`))) {
      this.errors.day = 'day must exist in selected month'
    }
  }
}
