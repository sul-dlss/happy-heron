import { Controller } from "stimulus"

// Opens the modal for the user to select a work type and subtypes when they
// indicate they would like to start a new deposit.
// This must be wrapped around the WorkTypeModalComponent because that renders
// all of the targets that this script expects.
export default class extends Controller {
  static targets = [
    "form", "template", "otherTemplate", "subtype", "area", "templateHeader",
    "moreTypesLink", "moreTypes", "continueButton",
    "musicTemplateSubheader", "mixedMaterialTemplateSubheader"
  ]

  connect() {
    this.requiredSubtypeCount = 0
  }

  // Sets the form in the popup to use the action in the data-destination attribute
  setCollection(event) {
    event.preventDefault()
    // Use currentTarget (instead of target) because it gets the element with the Stimulus data attributes. Useful
    // when the data attributes and Stimulus action are defined on an element that wraps other elements. E.g. when an
    // a tag wraps a span tag with an icon (with the Stimulus data on the a tag), if the user clicks the linked span
    // icon, target is the span and currentTarget is the anchor.
    this.formTarget.action = event.currentTarget.dataset.destination
    if (event.currentTarget.dataset.formMethod) {
      this.formTarget.method = event.currentTarget.dataset.formMethod
    } else {
      // reset to default in case prior caller popped used model with non-default
      this.formTarget.method = 'get'
    }
  }

  change(event) {
    const type = event.target.value

    // We treat the "other" work type differently than all the others.
    type === 'other' ?
      this.displayOtherSubtypeOptions() :
      this.displaySubtypeOptions(type)

    // Display the work type choices
    this.areaTarget.hidden = false

    // Set the number of required subtypes
    switch(type) {
      case 'music':
        this.requiredSubtypeCount = 1
        break
      case 'mixed material':
        this.requiredSubtypeCount = 2
        break
      default:
        this.requiredSubtypeCount = 0
    }
  }

  toggleMoreTypes(event) {
    event.preventDefault()

    this.moreTypesTarget.hidden ?
      this.showMoreTypes() :
      this.hideMoreTypes()
  }

  showMoreTypes() {
    this.moreTypesTarget.hidden = false
    this.moreTypesLinkTarget.innerHTML = 'See fewer options'
    this.moreTypesLinkTarget.classList.toggle('collapsed', false)
    this.continueButtonTarget.focus()
  }

  hideMoreTypes() {
    this.moreTypesTarget.hidden = true
    this.moreTypesLinkTarget.innerHTML = 'See more options'
    this.moreTypesLinkTarget.classList.toggle('collapsed', true)
  }

  displaySubtypeOptions(type) {
    // Show the more options link
    this.moreTypesLinkTarget.hidden = false
    this.subtypeTarget.hidden = false
    this.subtypeTarget.innerHTML = this.subtypesFor(type).join('')
    this.moreTypesTarget.innerHTML = this.moreTypesFor(type).join('')
    this.areaTarget.innerHTML = this.templateHeaderTarget.innerHTML
    switch(type) {
      case 'music':
        this.areaTarget.innerHTML += this.musicTemplateSubheaderTarget.innerHTML
        break
      case 'mixed material':
        this.moreTypesLinkTarget.hidden = true
        this.areaTarget.innerHTML += this.mixedMaterialTemplateSubheaderTarget.innerHTML
        break
    }
  }

  displayOtherSubtypeOptions() {
    // Hide the more options link
    this.moreTypesLinkTarget.hidden = true
    this.hideMoreTypes()
    this.subtypeTarget.hidden = true
    this.areaTarget.innerHTML = this.otherTemplateTarget.innerHTML
  }

  subtypesFor(type) {
    return document
      .subtypes[type]
      .map((subtype)=> {
        const id = subtype.replace(/\s/g, '_')
        return this.templateTarget.innerHTML.replace(/SUBTYPE_LABEL/g, subtype).replace(/SUBTYPE_ID/g, id)
      })
  }

  moreTypesFor(type) {
    // Work types have a small number of primary subtypes and they share a large
    // number of general subtypes, which we refer to as "more types." Some work types
    // appear in the list of "more types" and also have primary subtypes that can appear
    // in the list of "more types" and we don't want users to be able to see and select
    // multiple types of the exact same value, so we only return the "more types" that
    // do not match the type or any of the type's primary subtypes, hence the filtering
    // in this function.
    return document
      .moreTypes
      .filter(moreType => (!document.subtypes[type].includes(moreType) && type !== moreType.toLowerCase()))
      .map((moreType) => {
        const id = moreType.replace(/\s/g, '_')
        return this.templateTarget.innerHTML.replace(/SUBTYPE_LABEL/g, moreType).replace(/SUBTYPE_ID/g, id)
      })
  }

  checkSubtypes() {    
    const checked = this.formTarget.querySelectorAll('div.subtype-container input[type="checkbox"]:checked')
    const firstInput = this.formTarget.querySelector('div.subtype-container input[type="checkbox"]:not(:checked)')
    const inputs = this.formTarget.querySelectorAll('div.subtype-container input[type="checkbox"]')
    inputs.forEach((input) => {      
      input.setCustomValidity('')
    })
    if (checked.length < this.requiredSubtypeCount) {
      firstInput.setCustomValidity(`Please select ${this.requiredSubtypeCount} or more subtype options.`)
    }
  }
}
