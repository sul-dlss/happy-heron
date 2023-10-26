import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['checkbox']

  checkAll (event) {
    event.preventDefault()
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = true
    })
  }

  checkNone (event) {
    event.preventDefault()
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = false
    })
  }
}
