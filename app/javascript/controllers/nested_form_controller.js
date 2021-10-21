import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["add_item", "template"]
  static values = { selector: String }

  addAssociation(event) {
    if(event) event.preventDefault()
    this.add_itemTarget.insertAdjacentHTML('beforebegin', this.buildNewRowFromTemplate())
  }

  removeAssociation(event) {
    event.preventDefault()
    const item = this.getItemForButton(event.target)
    item.querySelectorAll('input').forEach((element) => element.required = false)
    item.querySelector("input[name*='_destroy']").value = 1
    item.style.display = 'none'

    if(this.isEmpty()) this.addAssociation()
  }

  getItemForButton(button) {
    return button.closest(this.selectorValue)
  }

  buildNewRowFromTemplate() {
    return this.templateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, new Date().valueOf())
  }

  // Returns true if there are no visible rows on this form.
  isEmpty() {
    return Array.from(this.element.querySelectorAll(this.selectorValue)).find(node => node.style.display === '') === undefined
  }
}