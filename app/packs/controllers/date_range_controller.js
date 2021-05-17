import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["year"]

  // If any of the years are filled in, then make both required.
  change(_event) {
   const filledIn = this.yearTargets.find((target) => target.value !== '')
   this.yearTargets.forEach((target) => target.required = filledIn)
  }
}
