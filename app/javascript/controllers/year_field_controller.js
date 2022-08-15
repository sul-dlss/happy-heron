import { Controller } from "stimulus"

export default class extends Controller {
  
  connect() {
    this.hasChanged = false
  }

  // On the first change, if they press the arrow keys or arrow buttons (on the page),
  // Then default it to the max value.  The default behavior is to default to the minimum value.
  change(evt) {
    if (this.hasChanged)
        return // nothing to do

    if (evt.inputType === "insertReplacementText") // So that typing in digits doesn't do this, only arrow keys or the arrow buttons
    evt.target.value = evt.target.max
    this.hasChanged = true
  }
}
