import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['collections', 'helpHow']

  connect () {
    this.changeHelpHow({ target: this.helpHowTarget })
  }

  changeHelpHow (event) {
    event.target.value === 'Request access to another collection' ? this.showCollections() : this.hideCollections()
  }

  showCollections () {
    this.collectionsTarget.hidden = false
  }

  hideCollections () {
    this.collectionsTarget.hidden = true
  }

  checkCollections () {
    const checked = this.collectionsTarget.querySelector('input[type="checkbox"]:checked')
    const firstInput = this.collectionsTarget.querySelector('input[type="checkbox"]')
    checked || this.collectionsTarget.hidden ? firstInput.setCustomValidity('') : firstInput.setCustomValidity('Please select an option.')
  }
}
