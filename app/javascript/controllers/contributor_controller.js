import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["personName", "organizationName", "role"]

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
    this.organizationNameTarget.hidden = false
  }

  displayPerson() {
    this.personNameTargets.forEach((element) => element.hidden = false)
    this.organizationNameTarget.hidden = true
  }
}
