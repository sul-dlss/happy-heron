import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "checkedSection", "uncheckedSection"]

  connect() {
    this.toggleInputs()
  }

  toggleInputs(event) {
    if(this.checkboxTarget.checked) {
      this.toggle(this.checkedSectionTarget, this.uncheckedSectionTarget, !!event)
    } else {
      this.toggle(this.uncheckedSectionTarget, this.checkedSectionTarget, !!event)
    }
  }

  toggle(target, source, copy) {
    // Toggle visibility
    target.hidden = false
    source.hidden = true

    // Toggle disabled
    const targetInputs = target.querySelectorAll('select,input[type="number"],input[type="checkbox"]')
    targetInputs.forEach((element) => element.disabled = false)

    const sourceInputs = source.querySelectorAll('select,input[type="number"],input[type="checkbox"]')
    sourceInputs.forEach((element) => element.disabled = true)

    if(copy) this.copy(targetInputs, sourceInputs)
  }

  copy(targetInputs, sourceInputs) {
    // Copy source values to target
    for (let i = 0; i < Math.min(targetInputs.length, sourceInputs.length); i++) {
      if(targetInputs[i].type == 'checkbox') {
        targetInputs[i].checked = sourceInputs[i].checked
      } else {
        targetInputs[i].value = sourceInputs[i].value
      }

      // This triggers the other controllers so that they can validate, etc.
      if(targetInputs[i].tagName == 'SELECT') {
        targetInputs[i].dispatchEvent(new Event('change'))
      } else {
        targetInputs[i].dispatchEvent(new Event('input'))
      }
    }
  }
}
