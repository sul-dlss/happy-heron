import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["title", "titleField",
                    "file", "fileField",
                    "keywordsField", "contributorsField",
                    "embargo-dateField"];

  connect() {
    // TODO see what of the things are already valid
    this.checkField(this.fileFieldTarget)
    this.checkField(this.titleFieldTarget)
  }

  check(e) {
    this.checkField(e.target)
  }

  checkField(field) {
    const stepName = field.getAttribute("data-progress-step")
    const step = this.targets.find(stepName)
    let isComplete = field.value !== ''
    // For files look for hidden inputs
    if (stepName === 'file') {
      isComplete = document.querySelectorAll('[type=hidden][name="work[files][]"]').length > 0
    }
    step.classList.toggle('active', isComplete)
  }

  displayErrors(event) {
    const [data, _status, xhr] = event.detail;
    switch (xhr.status) {
      case 400:
        this.parseErrors(data)
        break
      default:
        alert("There was an error with your request.")
        break
    }
  }

  parseErrors(data) {
    for (const [fieldName, errorList] of Object.entries(data)) {
      const key = `${fieldName}Field`
      const target = this.targets.find(key)
      if (target)
        target.dispatchEvent(new CustomEvent('error', { detail: errorList }))
      else
        console.error(`unable to find target for ${key}`)
    }
    window.scrollTo(0, 80)
  }
}
