import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["add_item", "template"]

  addAssociation(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().valueOf())
    this.add_itemTarget.insertAdjacentHTML('beforebegin', content)
  }

  removeAssociation(event) {
    event.preventDefault()
    const item = event.target.closest(".inner-container") || event.target.closest(".plain-container")
    item.querySelectorAll('input').forEach((element) => element.required = false)
    item.querySelector("input[name*='_destroy']").value = 1
    item.style.display = 'none'
  }
}
