import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["moreTypesLink",
                    "moreTypes",
                    "frame"]
  static values = { endpoint: String }

  connect() {
    this.check()
    this.element.addEventListener('change', () => this.check())
  }

  check(e) {
    const form = this.element
    const data = new FormData(form)

    // Discard any template records
    for(const key of data.keys()) {
      if (key.match(/TEMPLATE_RECORD/)) {
        data.delete(key)
      }
    }

    const queryString = new URLSearchParams(data).toString();
    this.frameTarget.src = `${this.endpointValue}?${queryString}`
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
