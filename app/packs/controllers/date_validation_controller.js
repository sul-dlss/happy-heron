import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["year", "month", "day"]

  change() {
    this.errors = {}
    this.mostSignifcantPartsPresent()
    this.dateInPast()
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
  }

  dateInPast() {
    const currentTime = new Date()
    const currentMonth = currentTime.getMonth() + 1
    const currentDay = currentTime.getDate()
    const currentYear = currentTime.getFullYear()
    const day = this.dayTarget.value
    const month = this.monthTarget.value
    const year = this.yearTarget.value

    if (year > currentYear) {
      this.errors.year = 'must be in the past'
    } else if (year == currentYear) {
      if (month > currentMonth) {
        this.errors.month = 'must be in the past'
      } else if (month == currentMonth && day > currentDay) {
        this.errors.day = 'must be in the past'
      }
    }
  }

  // Validate that the most signifcant parts are provided when a less significant part is provided.
  mostSignifcantPartsPresent() {
    const day = this.dayTarget.value
    const month = this.monthTarget.value
    const year = this.yearTarget.value

    if ((day || month) && !year) {
      this.errors.year = 'must be provided'
    } else if (day && !month) {
      this.errors.month = 'must be provided'
    }
  }
}
