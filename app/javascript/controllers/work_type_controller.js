import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["form", "template", "otherTemplate", "subtype", "area"]

  // Sets the form in the popup to use the action in the data-destination attribute
  set_collection(event) {
    event.preventDefault()
    this.formTarget.action = event.target.dataset.destination
  }

  change(event) {
    const type = event.target.value

    // We treat the "other" work type differently than all the others.
    type === 'other' ?
      this.displayOtherSubtypeOptions() :
      this.displaySubtypeOptions(type)

    // Display the work type choices
    this.areaTarget.hidden = false
  }

  displaySubtypeOptions(type) {
    const subtypes = document.subtypes[type].map((subtype)=> {
      const id = subtype.replace(/\s/g, '_')
      return this.templateTarget.innerHTML.replace(/SUBTYPE_LABEL/g, subtype).replace(/SUBTYPE_ID/g, id)
    })
    this.subtypeTarget.innerHTML = subtypes.join('')
    this.areaTarget.innerHTML = '<h5>Which of the following terms further describe your deposit?</h5>'
  }

  displayOtherSubtypeOptions() {
    this.subtypeTarget.innerHTML = this.otherTemplateTarget.innerHTML
    this.areaTarget.innerHTML = '<h5>Specify "Other" type</h5>'
  }
}
