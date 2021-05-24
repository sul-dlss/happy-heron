import { Controller } from "stimulus"

export default class extends Controller {
  // Currently webbrowsers don't have a problem submitting disabled options,
  // so we add validation that prevents that.
  connect() {
    this.validate()
  }

  validate(_event) {
    if (this.isSelectedOptionDisabled)
      this.element.setCustomValidity('Select a valid option')
    else
      this.element.setCustomValidity('')
  }

  get isSelectedOptionDisabled() {
    return this.element.selectedOptions[0].disabled
  }
}
