import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["form", "results"]

  displaySuccess(event) {
    const [data, _status, _xhr] = event.detail
    this.formTarget.hidden = true
    if (data.status === 'success') {
      this.resultsTarget.hidden = false
    }

  }
}
