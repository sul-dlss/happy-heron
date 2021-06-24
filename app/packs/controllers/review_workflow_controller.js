import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "enabled", "reviewers" ]

  connect() {
    this.toggle()
  }

  toggle() {
    this.reviewersTarget.disabled = !this.enabledTarget.checked
  }
}
