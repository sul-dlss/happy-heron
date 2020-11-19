import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["form", "results"]

  connect() {}

  displaySuccess(event) {
    const [data, _status, _xhr] = event.detail
    this.formTarget.hidden = true
    if (data.status === 'success') {
      const h2 = document.createElement("h2")
      h2.innerText = 'Help request successfully sent'
      this.resultsTarget.appendChild(h2)
      const textDiv = document.createElement("div")
      textDiv.innerText = `You should receive a response from our team within 48 hours.\n`
      const closeBtn = document.createElement("button")
      closeBtn.innerText = `Close`
      closeBtn.classList.add('btn')
      closeBtn.classList.add('btn-primary')
      closeBtn.setAttribute('data-dismiss', 'modal')
      textDiv.appendChild(closeBtn)
      this.resultsTarget.appendChild(textDiv)
    }

  }
}
