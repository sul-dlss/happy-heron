import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["reason", "text"]

  connect() {
    this.hide()
  }

  hide() {
    this.children().forEach((child) => child.hidden = true)
    this.textTarget.required = false
  }

  reveal() {
    this.children().forEach((child) => child.hidden = false)
    this.textTarget.required = true
  }

  children() {
    return Array.from(this.reasonTarget.children)
  }
}
