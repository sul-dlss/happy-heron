import bootstrap from 'bootstrap/dist/js/bootstrap'
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    return new bootstrap.Popover(this.element, {
      container: 'body',
      trigger: 'focus'
    })
  }
}
