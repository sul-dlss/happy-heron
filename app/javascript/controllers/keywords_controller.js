import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["search", "container", "error", "selectedTemplate", "addItem", "input"]

  connect() {
    // Prevent invalid keywords entered on the draft form from being submitted as a deposit
    // by marking them invalid
    this.checkForDuplicates()
  }

  open(event) {
    this.searchTarget.focus()
    this.containerTargets.forEach((container) => container.classList.add('keywords-container-open') )
  }

  close(event) {
    this.containerTargets.forEach((container) => container.classList.remove('keywords-container-open') )
  }

  checkForDuplicates() {
    if (this.hasDuplicateKeywords()) {
      this.inputTarget.classList.add('is-invalid')
      // Adding this custom validation to prevent the deposit from being submitted. See validate-forms.js
      this.inputTarget.setCustomValidity('has a duplicate')
    } else {
      this.inputTarget.classList.remove('is-invalid')
      this.inputTarget.setCustomValidity('')
    }
  }

  hasDuplicateKeywords() {
    // determine if the user has entered duplicate keywords
    const nodes = document.querySelectorAll('.keyword-row:not([style*="display: none"]) input[type="text"]')
    const keywords = Array.from(nodes, target => target.value)
    // a set cannot have duplicates but an array can, so if the set and array are different in size, we have dupes
    return (new Set(keywords)).size !== keywords.length
  }
}
