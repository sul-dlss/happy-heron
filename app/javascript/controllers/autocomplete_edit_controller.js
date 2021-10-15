import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["uri", "input", "value", "type"]

  connect() {
    this.change()
  }

  change() {
    if(this.valueTarget.value) {
      this.inputTarget.readOnly = true
      const [uri, cocina_type] = this.valueTarget.value.split('::')
      this.uriTarget.value = uri
      this.typeTarget.value = cocina_type
    }
  }
}
