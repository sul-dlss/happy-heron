import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["moreTypesLink", "moreTypes"]

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
