import { Controller } from "stimulus"

export default class extends Controller {
  static values = {
    id: String
  }

  show() {
    document.getElementById(this.idValue).classList.remove("d-none")
  }
}
