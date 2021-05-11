import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["year", "month", "day"]

  change() {
    const day = this.dayTarget.value
    const month = this.monthTarget.value
    const year = this.yearTarget.value
    if ((day || month) && !year) {
      this.yearTarget.classList.add('is-invalid')
      this.yearTarget.setCustomValidity('must be provided')
    } else {
      this.yearTarget.setCustomValidity('')
      this.yearTarget.classList.remove('is-invalid')
      if (day && !month) {
        this.monthTarget.setCustomValidity('must be provided')
        this.monthTarget.classList.add('is-invalid')
      } else {
        this.monthTarget.setCustomValidity('')
        this.monthTarget.classList.remove('is-invalid')
      }
    }
  }
}
