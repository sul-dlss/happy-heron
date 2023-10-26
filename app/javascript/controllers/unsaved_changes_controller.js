import { Controller } from '@hotwired/stimulus'

const LEAVING_PAGE_MESSAGE = 'Are you sure you want to leave this page? Your changes will not be saved.'

export default class extends Controller {
  connect () {
    this.isChanged = false
  }

  changed (event) {
    this.isChanged = true
  }

  leavingPage (event) {
    if (this.isChanged) {
      if (event.type === 'turbo:before-visit') {
        if (!window.confirm(LEAVING_PAGE_MESSAGE)) {
          event.preventDefault()
        }
      } else {
        event.returnValue = LEAVING_PAGE_MESSAGE
        return event.returnValue
      }
    }
  }

  allowFormSubmission (event) {
    this.isChanged = false
  }

  setChanged (changed) {
    this.data.set('changed', changed)
  }

  isFormChanged () {
    return this.data.get('changed') === 'true'
  }
}
