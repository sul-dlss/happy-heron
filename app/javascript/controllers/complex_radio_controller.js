import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['selection']

  connect () {
    this.disableUnselectedInputs()
  }

  disableUnselectedInputs () {
    this.selectionTargets.forEach((target) => {
      const checked = target.querySelector("input[type='radio']").checked
      // If radio is checked, enable its child select elements; if unchecked, disable.
      target.querySelectorAll('select,input[type="number"],input[type="checkbox"],fieldset,button,textarea')
        .forEach((element) => {
          element.disabled = !checked
        })
    })
  }
}
