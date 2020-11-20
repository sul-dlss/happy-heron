import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ['reviewerSunetsField'];

  displayErrors(event) {
    const [data, _status, _xhr] = event.detail;
    for (const [fieldName, errorList] of Object.entries(data)) {
      const key = `${fieldName}Field`
      const target = this.targets.find(key)
      if (target)
        target.dispatchEvent(new CustomEvent('error', { detail: errorList }))
      else
        console.error(`unable to find target for ${key}`)
    }
  }
}
