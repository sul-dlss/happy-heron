import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["frame"]
  static values = { endpoint: String }

  connect() {
    this.check()
    this.element.addEventListener('change', () => this.check())
  }

  // Trigger the progress component to re-render on each change
  check(e) {
    const form = this.element
    const data = new FormData(form)

    // Discard any template records
    for(const key of data.keys()) {
      if (key.match(/TEMPLATE_RECORD/)) {
        data.delete(key)
      }
    }

    const queryString = new URLSearchParams(data).toString();
    this.frameTarget.src = `${this.endpointValue}?${queryString}`
  }
}
