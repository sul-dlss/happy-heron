import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["personName", "organizationName", "role", "personNameInput", "organizationNameInput"]

  connect() {
    this.updateDisplay()
  }

  typeChanged() {
    this.updateDisplay()
  }

  updateDisplay() {
    if (this.roleTarget.value.startsWith('person'))
      this.displayPerson()
    else
      this.displayOrganization()
  }

  displayOrganization() {
    this.personNameTargets.forEach((element) => element.hidden = true)
    this.personNameInputTargets.forEach((element) => element.required = false)
    this.organizationNameTarget.hidden = false
    this.organizationNameInputTarget.required = true
  }

  displayPerson() {
    this.personNameTargets.forEach((element) => element.hidden = false)
    this.personNameInputTargets.forEach((element) => element.required = true)
    this.organizationNameTarget.hidden = true
    this.organizationNameInputTarget.required = false
  }
}
