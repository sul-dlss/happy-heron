import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    id: String
  }

  show () {
    document.getElementById(this.idValue).classList.remove('d-none')
  }
}
