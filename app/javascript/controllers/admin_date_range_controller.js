import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['start', 'end']

  connect () {
    this.change()
  }

  change () {
    this.endTarget.setCustomValidity('')
  }
}
