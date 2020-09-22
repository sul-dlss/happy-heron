import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["title", "titleField"];

  connect() {
    // TODO see what of the things are already valid
    this.checkField(this.titleFieldTarget)
  }

  check(e) {
    this.checkField(e.target)
  }

  checkField(field) {
    const stepName = field.getAttribute("data-progress-step")
    const step = this.targets.find(stepName)
    if (field.value === '')
      step.classList.remove('active')
    else
      step.classList.add('active')
  }
}
