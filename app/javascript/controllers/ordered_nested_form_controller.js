import NestedFormController from "./nested_form_controller"

export default class extends NestedFormController {
  connect() {
    this.renumber()
  }

  addAssociation(event) {
    super.addAssociation(event)
    // This depends on the superclass inserting the element before the add_itemTarget
    const element = this.add_itemTarget.previousElementSibling
    this.setWeight(element, this.count)
    this.rows().forEach((row, index) => {
      this.filterButtons(row, index)
    })
  }

  setWeight(element, value) {
    element.querySelector("input[name*='weight']").value = value
  }

  filterButtons(element, index) {
    this.upButtonTarget.hidden = (index == 0)
    this.downButtonTarget.hidden = (index == this.count - 1)
  }

  renumber() {
    this.rows().forEach((row, index) => {
      this.setWeight(row, index)
      this.filterButtons(row, index)
    })
  }

  moveUp(event) {
    const item = this.getItemForButton(event.target)
    const previous = item.previousElementSibling
    previous.remove()
    item.insertAdjacentElement('afterend', previous)
    this.renumber()
  }

  moveDown(event) {
    const item = this.getItemForButton(event.target)
    const next = item.nextElementSibling
    next.remove()
    item.insertAdjacentElement('beforebegin', next)
    this.renumber()
  }

  removeAssociation(event) {
    super.removeAssociation(event)
    this.renumber()
  }

  get count() {
    return this.rows().length
  }

  // Returns all of the not deleted rows (we don't want controls showing if there is only one visibile row, but many deleted rows)
  rows() {
    const allRows = this.element.querySelectorAll(this.selectorValue)
    return Array.from(allRows).filter((item) => item.querySelector("input[name*='_destroy']").value != "1")
  }
}
