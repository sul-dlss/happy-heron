import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selection"]

  connect() {
    this.disableUnselectedInputs();
  }

  disableUnselectedInputs(_event) {
    this.selectionTargets.forEach((target) => {
      const checked = target.querySelector("input[type='radio']").checked
      // If radio is checked, enable its child select elements; if unchecked, disable.
      target.querySelectorAll('select,input[type="number"],input[type="checkbox"],fieldset,button').forEach((element) => element.disabled = !checked)
    })
  }
}
