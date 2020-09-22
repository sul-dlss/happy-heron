import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["title", "titleField", "file", "fileField"];

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
}
