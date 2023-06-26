import { Controller } from "@hotwired/stimulus"

// Sets the form when the admin is changing the work type and subtypes of an existing work.
// This must be wrapped around the WorkTypeModalComponent because that renders
// all of the targets that this script expects.
export default class extends Controller {
  static targets = [
    "form"
  ]

  static outlets = [
    "work-type-modal"
  ]

  static values = {
    id: String,
    action: String,
    workType: String,
    workSubtype: Array
  }

  connect() {    
    this.formTarget.action = this.actionValue
    bootstrap.Modal.getOrCreateInstance(this.idValue).show()
    this.workTypeModalOutlet.selectType(this.workTypeValue)
    this.workSubtypeValue.forEach(subtype => this.workTypeModalOutlet.selectSubtype(subtype))
  }
}
