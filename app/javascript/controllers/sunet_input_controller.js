import { Controller } from '@hotwired/stimulus'
import debounce from 'lodash.debounce'

export default class extends Controller {
  static targets = ['result', 'resultNone', 'resultOne', 'resultName', 'resultDescription', 'queryValue',
    'resultError', 'errorValue', 'submit']

  connect () {
    this.search = debounce(this.search, 700)
    this.submitTarget.disabled = true
    this.hideResult()
  }

  hideResult () {
    this.showResult(false, false, false)
  }

  showResult (one, none, error) {
    this.resultOneTarget.hidden = !one
    this.resultNoneTarget.hidden = !none
    this.resultErrorTarget.hidden = !error
  }

  search (e) {
    // only execute a search if the user has entered at least 3 characters that doesn't start with a number
    if (e.target.value.length < 3 || /^\d/.test(e.target.value)) {
      this.hideResult()
      return
    }

    // remove non-letters/numbers, and truncate after 8 characters
    e.target.value = e.target.value.replace(/[^a-zA-Z0-9]/g, '').substring(0, 8)
    fetch('/accounts/' + e.target.value)
      .then((response) => {
        if (response.ok) {
          return response.json()
        } else {
          throw new Error(response.statusText)
        }
      })
      .then(data => {
        if (Object.keys(data).length === 0) { this.noResults(e.target.value) } else { this.showOneResult(data) }
      })
      .catch(error => this.showError(error))
  }

  noResults (query) {
    this.showResult(false, true, false)
    this.queryValueTargets.forEach(target => {
      target.innerHTML = query
    })
    this.submitTarget.disabled = true
  }

  showOneResult (data) {
    this.showResult(true, false, false)
    this.resultNameTarget.innerHTML = data.name
    this.resultDescriptionTarget.innerHTML = data.description
    this.submitTarget.disabled = false
  }

  showError (error) {
    this.showResult(false, false, true)
    this.errorValueTarget.innerHTML = error.toString()
    this.submitTarget.disabled = true
  }
}
