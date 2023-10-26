import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['uri', 'input', 'value', 'type']

  connect () {
    this.change()
  }

  change () {
    if (this.valueTarget.value) {
      const [uri, cocinaType] = this.valueTarget.value.split('::')
      this.uriTarget.value = uri
      this.typeTarget.value = cocinaType
    }
  }
}
