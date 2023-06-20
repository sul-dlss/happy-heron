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

    // Be careful refactoring this because Firefox and Chrome send different event types when doing arrow buttons
    // We prevent this behavior when typing or pasting, we only want it for arrow keys or the arrow buttons
    const typeEvents = ["insertText", "insertFromPaste", "deleteContentBackward"]
    if (!typeEvents.includes(evt.inputType))
      evt.target.value = evt.target.max
    this.hasChanged = true
  }
}
