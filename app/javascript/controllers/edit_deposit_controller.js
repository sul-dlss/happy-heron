import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["title", "titleField", "file", "fileField", "keywordsField"];

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
    const [data, _status, _xhr] = event.detail;

    for (const [fieldName, errorList] of Object.entries(data)) {
      const target = this.targets.find(`${fieldName}Field`)
      const container = target.querySelector(`.${fieldName}-container`)
      container.classList.toggle('is-invalid')
      const feedback = target.querySelector('.invalid-feedback')
      feedback.innerHTML += errorList.join(' ')
    }
  }
}
