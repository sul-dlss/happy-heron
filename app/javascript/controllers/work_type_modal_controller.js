import { Controller } from '@hotwired/stimulus'

// Manipulates work types and subtypes within the work type modal
export default class extends Controller {
  static targets = [
    'form', 'template', 'otherTemplate', 'subtype', 'area', 'templateHeader',
    'moreTypesLink', 'moreTypes', 'continueButton',
    'musicTemplateSubheader', 'mixedMaterialTemplateSubheader'
  ]

  connect () {
    this.requiredSubtypeCount = 0
  }

  change (event) {
    this.changeType(event.target.value)
  }

  changeType (type) {
    // We treat the "other" work type differently than all the others.
    type === 'other'
      ? this.displayOtherSubtypeOptions()
      : this.displaySubtypeOptions(type)

    // Display the work type choices
    this.areaTarget.hidden = false

    // Set the number of required subtypes
    switch (type) {
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

  selectType (type) {
    const input = this.formTarget.querySelector(`input[value="${type}"]`)
    input.checked = true
    this.changeType(type)
  }

  selectSubtype (subtype) {
    const input = this.formTarget.querySelector(`input[value="${subtype}"]`)
    input.checked = true
  }

  toggleMoreTypes (event) {
    event.preventDefault()

    this.moreTypesTarget.hidden
      ? this.showMoreTypes()
      : this.hideMoreTypes()
  }

  showMoreTypes () {
    this.moreTypesTarget.hidden = false
    this.moreTypesLinkTarget.innerHTML = 'See fewer options'
    this.moreTypesLinkTarget.classList.toggle('collapsed', false)
    this.moreTypesLinkTarget.setAttribute('aria-expanded', true)
    this.continueButtonTarget.focus()
  }

  hideMoreTypes () {
    this.moreTypesTarget.hidden = true
    this.moreTypesLinkTarget.innerHTML = 'See more options'
    this.moreTypesLinkTarget.classList.toggle('collapsed', true)
    this.moreTypesLinkTarget.setAttribute('aria-expanded', false)
  }

  displaySubtypeOptions (type) {
    // Show the more options link
    this.moreTypesLinkTarget.hidden = false
    this.subtypeTarget.hidden = false
    this.subtypeTarget.innerHTML = this.subtypesFor(type).join('')
    this.moreTypesTarget.innerHTML = this.moreTypesFor(type).join('')
    this.areaTarget.innerHTML = this.templateHeaderTarget.innerHTML
    switch (type) {
      case 'music':
        this.areaTarget.innerHTML += this.musicTemplateSubheaderTarget.innerHTML
        break
      case 'mixed material':
        this.moreTypesLinkTarget.hidden = true
        this.areaTarget.innerHTML += this.mixedMaterialTemplateSubheaderTarget.innerHTML
        break
    }
  }

  displayOtherSubtypeOptions () {
    // Clear checked subtypes
    this.formTarget.querySelectorAll('div.subtype-container input[type="checkbox"]:checked').forEach((input) => {
      input.checked = false
    })
    // Hide the more options link
    this.moreTypesLinkTarget.hidden = true
    this.hideMoreTypes()
    this.subtypeTarget.hidden = true
    this.areaTarget.innerHTML = this.otherTemplateTarget.innerHTML
  }

  subtypesFor (type) {
    return document
      .subtypes[type]
      .map((subtype) => {
        const id = subtype.replace(/\s/g, '_')
        return this.templateTarget.innerHTML.replace(/SUBTYPE_LABEL/g, subtype).replace(/SUBTYPE_ID/g, id)
      })
  }

  moreTypesFor (type) {
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

  checkSubtypes () {
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
