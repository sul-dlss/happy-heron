import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    new bootstrap.Popover(this.element, {
      container: 'body',
      trigger: 'focus'
    })
  }
}
