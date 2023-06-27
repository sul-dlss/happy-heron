import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["startYear", "startMonth", "startDay", "endYear", "endMonth", "endDay", "startError", "endError"]

    connect() {
        this.change()
    }

    // This invokes Date Validation controller as necessary for start and end dates.
    change() {
        this.clearValidationMessages()
        this.validate()
    }

    validate() {
        this.startYearTarget.dispatchEvent(new Event('validate'))
        this.endYearTarget.dispatchEvent(new Event('validate'))
        const filled = this.dateFilled()
        if(filled) this.dateOrder()
    }

    clearValidationMessages() {
        this.startYearTarget.dispatchEvent(new Event('clear'))
        this.startErrorTarget.textContent = ''
        this.endYearTarget.dispatchEvent(new Event('clear'))
        this.endErrorTarget.textContent = ''
    }

    // If any of the years are filled in, then make both required.
    dateFilled() {
        if (!this.filledIn(this.startYearTarget) && !this.filledIn(this.endYearTarget)) return
        if (!this.filledIn(this.startYearTarget)) {
          this.startYearTarget.required = true
          this.startYearTarget.classList.add('is-invalid')
          this.startErrorTarget.textContent = "start must be provided"
          return false
        }
        if (!this.filledIn(this.endYearTarget)) {
          this.endYearTarget.required = true
          this.endYearTarget.classList.add('is-invalid')
          this.endErrorTarget.textContent = "end must be provided"
          return false
        }
        return true
    }

    dateOrder() {
        const startYear = this.toInt(this.startYearTarget)
        const startMonth = this.toInt(this.startMonthTarget)
        const startDay = this.toInt(this.startDayTarget)
        const endYear = this.toInt(this.endYearTarget)
        const endMonth = this.toInt(this.endMonthTarget)
        const endDay = this.toInt(this.endDayTarget)

        if(startYear == endYear && startMonth == endMonth && startDay === endDay) {
            this.startErrorTarget.textContent = 'start must be before end'
            this.startYearTarget.classList.add('is-invalid')
            this.startYearTarget.setCustomValidity('invalid')
            if(startMonth != 0) {
                this.startMonthTarget.classList.add('is-invalid')
                this.startMonthTarget.setCustomValidity('invalid')
            }
            if(startDay != 0) {
                this.startDayTarget.classList.add('is-invalid')
                this.startDayTarget.setCustomValidity('invalid')
            }
            return
        }

        if(startYear > endYear) {
            this.startErrorTarget.textContent = 'start must be before end'
            this.startYearTarget.classList.add('is-invalid')
            this.startYearTarget.setCustomValidity('invalid')
            return
        }
        if(startYear < endYear) return

        if(startMonth > endMonth) {
            this.startErrorTarget.textContent = 'start must be before end'
            this.startYearTarget.classList.add('is-invalid')
            this.startYearTarget.setCustomValidity('invalid')
            this.startMonthTarget.classList.add('is-invalid')
            this.startMonthTarget.setCustomValidity('invalid')
            return
        }

        if(startMonth < endMonth) return

        if(startDay > endDay) {
            this.startErrorTarget.textContent = 'start must be before end'
            this.startYearTarget.classList.add('is-invalid')
            this.startYearTarget.setCustomValidity('invalid')
            this.startMonthTarget.classList.add('is-invalid')
            this.startMonthTarget.setCustomValidity('invalid')
            this.startDayTarget.classList.add('is-invalid')
            this.startDayTarget.setCustomValidity('invalid')
            return
        }
    }

    filledIn(target) {
        return target.value !== ''
    }

    toInt(target) {
        return parseInt(target.value) || 0
    }
}
