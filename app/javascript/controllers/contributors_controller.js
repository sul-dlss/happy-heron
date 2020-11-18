import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["personName", "organizationName", "role", "personNameInput", "organizationNameInput", "container", "error"]

  connect() {
    this.updateDisplay()
  }

  inputChanged() {
    this.containerTarget.classList.remove('is-invalid')
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

  // Triggered when edit-deposit controller sends an error event
  error(e) {
    this.containerTarget.classList.add('is-invalid')
    this.errorTarget.innerHTML = e.detail.join(' ')
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
