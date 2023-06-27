import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["result", "resultNone", "resultOne", "resultName", "resultDruid", "queryValue",
  "resultError", "errorValue", "submit", "form", "collectionInput"]

  connect() {
    this.submitTarget.disabled = true
    this.hideResult()
  }

  hideResult() {
    this.showResult(false, false, false)
  }

  showResult(one, none, error) {
    this.resultOneTarget.hidden = !one
    this.resultNoneTarget.hidden = !none
    this.resultErrorTarget.hidden = !error
  }

  search(e) {
    // only execute a search if the user has entered a complete druid
    const druid = e.target.value.replace(/^(druid:)/,'')
    if(druid.length < 11) {
      this.hideResult()
      return
    }

    fetch(`${this.formTarget.action}/search?druid=${druid}`)
      .then((response) => {
        if(response.ok) {
          return response.json()
        } else {
          throw new Error(response.statusText)
        }
      })
      .then(data => {
        if (data.length == 0) return this.noResults(e.target.value)
        const collection = data[0]
        if (collection.errors.length > 0) return this.showOneResultWithErrors(collection)
        this.showOneResult(collection)
      })
      .catch(error => this.showFetchError(error))
  }

  noResults(query) {
    this.showResult(false, true, false)
    this.queryValueTargets.forEach(target => target.innerHTML = query)
    this.submitTarget.disabled = true
  }

  showOneResult(collection) {
    this.showResult(true, false, false)
    this.resultNameTarget.innerHTML = collection.name
    this.resultDruidTarget.innerHTML = collection.druid
    this.collectionInputTarget.value = collection.id
    this.submitTarget.disabled = false
  }

  showOneResultWithErrors(collection) {
    this.showResult(true, false, true)
    this.resultNameTarget.innerHTML = collection.name
    this.resultDruidTarget.innerHTML = collection.druid
    this.collectionInputTarget.value = collection.id
    this.errorValueTarget.innerHTML = `Cannot move to this collection because: ${collection.errors.join(' ')}`
    this.submitTarget.disabled = true
  }

  showFetchError(error) {
    this.showResult(false, false, true)
    this.errorValueTarget.innerHTML = `Error looking up collection: "${error.toString()}" - try again later`
    this.submitTarget.disabled = true
  }
}
