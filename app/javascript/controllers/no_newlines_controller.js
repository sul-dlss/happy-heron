import { Controller } from "@hotwired/stimulus"

// This controller removes newlines from an input such as a textarea.
// This allows the input to wrap long text.
export default class extends Controller {
  static targets = ["input"]

  change() {
    this.inputTarget.value = this.inputTarget.value.replace( /\r?\n/gi, '' )
  }
}
