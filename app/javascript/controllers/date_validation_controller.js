import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["year", "month", "day", "error"]

  connect() {
    this.validate()
  }

  change() {
    this.clearValidations()
    this.validate()
  }

  validate() {
    this.mostSignificantPartsPresent()
    this.validDateRange()
  }

  clearValidations() {
    this.yearTarget.classList.remove('is-invalid')
    this.yearTarget.setCustomValidity('')
    this.yearTarget.required = false
    this.monthTarget.classList.remove('is-invalid')
    this.monthTarget.setCustomValidity('')
    this.monthTarget.required = false
    this.dayTarget.classList.remove('is-invalid')
    this.dayTarget.setCustomValidity('')
    this.errorTarget.textContent = ''
  }

  validDateRange() {
    const currentTime = new Date()
    const currentMonth = currentTime.getMonth() + 1
    const currentDay = currentTime.getDate()
    const currentYear = currentTime.getFullYear()
    const day = this.toInt(this.dayTarget)
    const month = this.toInt(this.monthTarget)
    const year = this.toInt(this.yearTarget)

    if (year != 0 && year < this.yearTarget.min) {
      this.yearTarget.classList.add('is-invalid')
      this.yearTarget.setCustomValidity('invalid')
      this.errorTarget.textContent = 'must be after ' + this.yearTarget.min
    } else if (year > currentYear) {
      this.yearTarget.classList.add('is-invalid')
      this.yearTarget.setCustomValidity('invalid')
      this.errorTarget.textContent = 'must be in the past'
    } else if (year == currentYear) {
      if (month > currentMonth) {
        this.monthTarget.classList.add('is-invalid')
        this.monthTarget.setCustomValidity('invalid')
        this.yearTarget.classList.add('is-invalid')
        this.yearTarget.setCustomValidity('invalid')
        this.errorTarget.textContent = 'must be in the past'
      } else if (month == currentMonth && day > currentDay) {
        this.dayTarget.classList.add('is-invalid')
        this.dayTarget.setCustomValidity('invalid')
        this.monthTarget.classList.add('is-invalid')
        this.monthTarget.setCustomValidity('invalid')
        this.yearTarget.classList.add('is-invalid')
        this.yearTarget.setCustomValidity('invalid')
        this.errorTarget.textContent = 'must be in the past'
      }
    }
  }

  // Validate that the most signifcant parts are provided when a less significant part is provided.
  // Draft cannot be saved unless this is satisfied so should be displayed immediately.
  mostSignificantPartsPresent() {
    const day = this.dayTarget.value
    const month = this.monthTarget.value
    const year = this.yearTarget.value

    if ((day || month) && !year) {
      this.yearTarget.classList.add('is-invalid')
      this.yearTarget.required = true
    }
    if (day && !month) {
      this.monthTarget.classList.add('is-invalid')
      this.monthTarget.required = true
    }
  }

  toInt(target) {
    return parseInt(target.value) || 0
  }
}
