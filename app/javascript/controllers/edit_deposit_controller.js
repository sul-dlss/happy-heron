import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["title", "titleField",
                    "file", "fileField",
                    "keywordsField", "contributorsField",
                    "embargo-dateField", "terms", "termsField"];

  connect() {
    // TODO see what of the things are already valid
    this.checkField(this.fileFieldTarget)
    this.checkField(this.titleFieldTarget)
    this.checkField(this.termsFieldTarget)
  }

  check(e) {
    this.checkField(e.target)
  }

  checkField(field) {
    const stepName = field.getAttribute("data-progress-step")
    const step = this.targets.find(stepName)
    let isComplete = field.value !== ''
    if (stepName === 'file') {
      isComplete = document.querySelectorAll('.dz-preview').length > 0
    }
    if (stepName === 'terms') {
      isComplete = document.querySelector('#work_agree_to_terms').checked
    }
    step.classList.toggle('active', isComplete)
  }
}
