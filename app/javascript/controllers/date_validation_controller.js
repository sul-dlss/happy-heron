import { Controller } from "@hotwired/stimulus"

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

    if (!this.validateYearMin(year)) return
    if (!this.validateYearPast(year, currentYear, month, day)) return
    if (!this.validateMonthPast(year, currentYear, month, currentMonth, day)) return
    if (!this.validateDayPast(year, currentYear, month, currentMonth, day, currentDay)) return
    this.validateDayExists(month, day)
  }

  validateYearMin(year) {
    if (year != 0 && year < this.yearTarget.min) {
      this.invalid('must be after ' + this.yearTarget.min, false, false)
      return false
    }
    return true
  }

  validateYearPast(year, currentYear, month, day) {
    if (year > currentYear) {
      this.invalid('must be in the past', !!month, !!day)
      return false
    }
    return true
  }

  validateMonthPast(year, currentYear, month, currentMonth, day) {
    if (year == currentYear && month > currentMonth) {
      this.invalid('must be in the past', true, !!day)
      return false
    }
    return true
  }

  validateDayPast(year, currentYear, month, currentMonth, day, currentDay) {
    if (year == currentYear && month == currentMonth && day > currentDay) {
      this.invalid('must be in the past', true, true)
      return false
    }
    return true
  }

  validateDayExists(month, day) {
    if(!month || !day) return true

    const lastDays = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    if (lastDays[month - 1] < day) {
      this.invalid('must be a valid day', true, true)
      return false
    }
    return true
  }

  invalid(msg, invalid_month, invalid_day) {
    this.yearTarget.classList.add('is-invalid')
    this.yearTarget.setCustomValidity('invalid')  
    if(invalid_month) {
      this.monthTarget.classList.add('is-invalid')
      this.monthTarget.setCustomValidity('invalid')
    }
    if(invalid_day) {
      this.dayTarget.classList.add('is-invalid')
      this.dayTarget.setCustomValidity('invalid')
    }
    this.errorTarget.textContent = msg
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
