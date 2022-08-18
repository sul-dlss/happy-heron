import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["start", "end"]

    connect() {
        this.change()
    }

    change() {
        this.endTarget.setCustomValidity('')
        if(this.startTarget.value == '' || this.endTarget.value == '') {
            return
        }
        const startDate = new Date(this.startTarget.value)
        const endDate = new Date(this.endTarget.value)
        if(startDate < endDate) {
            return
        }
        this.endTarget.setCustomValidity('End date must be after start date')
    }
}
