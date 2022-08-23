import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["result", "resultNone", "resultOne", "resultName", "resultDescription", "queryValue", "submit"]
  
  connect() {
    this.resultOneTarget.hidden = true
    this.resultNoneTarget.hidden = true
    this.submitTarget.disabled = true
  }

  search(e) {
    // only execute a search if the user has entered at least 3 characters that doesn't start with a number
    if(e.target.value.length < 3 || /^\d/.test(e.target.value)) {
      this.resultTarget.hidden = true
      return
    }

    this.resultTarget.hidden = false

    // remove non-letters/numbers, and truncate after 8 characters
    e.target.value = e.target.value.replace(/[^a-zA-Z0-9]/g, '').substring(0,8)
    fetch('/accounts/' + e.target.value)
      .then(response => response.json())
      .then(data => {
        if (Object.keys(data).length === 0)
          this.noResults(e.target.value)
        else
          this.showResult(e.target.value, data)
      })
  }

  noResults(query) {
    this.resultOneTarget.hidden = true
    this.resultNoneTarget.hidden = false
    this.queryValueTargets.forEach(target => target.innerHTML = query)
    this.submitTarget.disabled = true
  }

  showResult(query, data) {
    this.resultOneTarget.hidden = false
    this.resultNoneTarget.hidden = true
    this.resultNameTarget.innerHTML = data.name
    this.resultDescriptionTarget.innerHTML = data.description
    this.submitTarget.disabled = false
  }
}
