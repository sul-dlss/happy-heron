import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["addItem", "template", "control", "result", "lookup",
                    "resultNone", "queryValue",
                    "resultOne", "resultName", "resultDescription"]
  static values = { selector: String }

  connect() {
    this.controlTarget.hidden = true
  }

  addAssociation(event) {
    if(event) event.preventDefault()
    const sunetid = this.sunet
    const name = this.resultNameTarget.innerHTML
    const elemtn =  this.buildNewRowFromTemplate(sunetid, name)
    this.controlTarget.insertAdjacentElement('beforebegin', elemtn)
    this.closeLookup()
  }

  removeAssociation(event) {
    event.preventDefault()
    const item = this.getItemForButton(event.target)
    item.querySelectorAll('input').forEach((element) => element.required = false)
    item.querySelector("input[name*='_destroy']").value = 1
    item.style.display = 'none'
  }

  getItemForButton(button) {
    return button.closest(this.selectorValue)
  }

  buildNewRowFromTemplate(sunetid, name) {
    const html = this.templateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().valueOf())
    const template =  document.createElement('template')
    template.innerHTML = html.trim() // Never return a text node of whitespace as the result
    const element = template.content.firstChild

    // Show the sunet and name
    element.querySelector('div > div > div').innerHTML = `${sunetid}: ${name}`

    // Set the hidden field
    element.querySelector('[data-target="sunetid"]').value = sunetid
    return element
  }

  isEmpty() {
    return Array.from(this.element.querySelectorAll(this.selectorValue)).find(node => node.style.display === '') === undefined
  }

  openLookup() {
    this.resultTarget.hidden = true
    this.controlTarget.hidden = false
  }

  closeLookup() {
    this.resultTarget.hidden = true
    this.controlTarget.hidden = true
    this.lookupTarget.value = ''
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

  clear(e) {
    this.sunet = e.target.value
    if (!this.hasResults) { this.closeLookup() }
  }

  preventEnter(e) {
    if (e.keyCode == 13) { e.preventDefault() }
  }
  noResults(query) {
    this.resultOneTarget.hidden = true
    this.resultNoneTarget.hidden = false
    this.queryValueTargets.forEach(target => target.innerHTML = query)
    this.hasResults = false
  }

  showResult(query, data) {
    this.resultOneTarget.hidden = false
    this.resultNoneTarget.hidden = true
    this.queryValueTargets.forEach(target => target.innerHTML = query)
    this.resultNameTarget.innerHTML = data.name
    this.resultDescriptionTarget.innerHTML = data.description
    this.hasResults = true
  }
}
