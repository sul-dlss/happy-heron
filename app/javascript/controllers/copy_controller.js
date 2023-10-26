import bootstrap from 'bootstrap/dist/js/bootstrap'
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    clip: String
  }

  copy (event) {
    navigator.clipboard.writeText(this.clipValue)
    event.preventDefault()

    const popover = new bootstrap.Popover(event.target, {
      content: 'Copied.',
      placement: 'top',
      trigger: 'manual'
    })
    popover.show()
    setTimeout(function () { popover.dispose() }, 1500)
  }
}
