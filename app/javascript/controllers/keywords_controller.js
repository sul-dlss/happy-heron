import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["search", "container", "error", "selectedTemplate", "addItem"]

  open(event) {
    this.searchTarget.focus()
    this.containerTargets.forEach((container) => container.classList.add('keywords-container-open') )
  }

  close(event) {
    this.containerTargets.forEach((container) => container.classList.remove('keywords-container-open') )
  }

  add(event) {
    const content = this.selectedTemplateTarget.innerHTML
      .replace(/TEMPLATE_RECORD/g, new Date().valueOf())
      .replace(/TEMPLATE_LABEL/g, event.target.value)

    this.searchTarget.value = ''
    this.addItemTarget.insertAdjacentHTML('beforeend', content)
    // Remove error indications when keyword(s) added
    this.containerTarget.classList.remove('is-invalid')
  }

  checkForDuplicates(event) {
    const input = event.target.closest('input[type="text"]')
    const keywords = Array.from(document.querySelectorAll('.keyword-row:not([style*="display: none"]) input[type="text"]'), input => input.value)
    const hasDuplicates = (new Set(keywords)).size !== keywords.length // a set cannot have duplicates, so this checks for dupes
    if (hasDuplicates) {
      input.classList.add('is-invalid')
    }
    else
    {
      input.classList.remove('is-invalid')
    }
  }

  removeAssociation(event) {
    const item = event.target.closest(".selection-choice")
    item.querySelector("input[name*='_destroy']").value = 1
    item.style.display = 'none'
    this.checkForDuplicates() // clear out the invalid selection class if there are no duplicates anymore
  }
}
