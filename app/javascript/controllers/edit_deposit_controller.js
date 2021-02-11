import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["title", "titleField",
                    "file", "fileField",
                    "keywordsField",
                    "contributorsField",
                    "embargo-dateField",
                    "terms", "termsField",
                    "moreTypesLink", "moreTypes"];

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

  toggleMoreTypes(event) {
    event.preventDefault()

    this.moreTypesTarget.hidden ?
      this.showMoreTypes() :
      this.hideMoreTypes()
  }

  showMoreTypes() {
    this.moreTypesTarget.hidden = false
    this.moreTypesLinkTarget.innerHTML = 'See fewer options'
    this.moreTypesLinkTarget.classList.toggle('collapsed', false)
  }

  hideMoreTypes() {
    this.moreTypesTarget.hidden = true
    this.moreTypesLinkTarget.innerHTML = 'See more options'
    this.moreTypesLinkTarget.classList.toggle('collapsed', true)
  }
}
