import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["form", "template", "subtype", "area"]

  // Sets the form in the popup to use the action in the data-destination attribute
  set_collection(event) {
    event.preventDefault()
    this.formTarget.action = event.target.dataset.destination
  }

  change(event) {
    this.areaTarget.hidden = false

    const type = event.target.value
    const subtypes = document.subtypes[type].map((subtype)=> {
      const id = subtype.replace(/\s/g, '_')
      return this.templateTarget.innerHTML.replace(/SUBTYPE_LABEL/g, subtype).replace(/SUBTYPE_ID/g, id)
    })
    this.subtypeTarget.innerHTML = subtypes.join('')
  }
}
