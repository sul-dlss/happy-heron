import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    new bootstrap.Popover(this.element, {
      container: 'body',
      trigger: 'focus'
    })
  }
}
