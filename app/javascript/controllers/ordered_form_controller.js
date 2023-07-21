import NestedForm from 'stimulus-rails-nested-form'

export default class extends NestedForm {

  connect() {
    super.connect()
    this.renumber()
  }

  add(event) {
    super.add(event)
    // This depends on the superclass inserting the element before target.
    const element = this.targetTarget.previousElementSibling
    this.setWeight(element, this.count)
    this.rows().forEach((row, index) => {
      this.filterButtons(row, index)
    })
  }

  remove(event) {
    super.remove(event)
    this.renumber()
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

  renumber() {
    this.rows().forEach((row, index) => {
      this.setWeight(row, index)
      this.filterButtons(row, index)
    })
  }

  setWeight(element, value) {
    element.querySelector("input[name*='weight']").value = value
  }

  filterButtons(element, index) {
    // Not setting these as targets, since overriding targets from superclass is problematic.
    element.querySelector(`button[data-${this.identifier}-target='upButton']`).hidden = (index == 0)
    element.querySelector(`button[data-${this.identifier}-target='downButton']`).hidden = (index == this.count - 1)
  }

  // Returns all of the not deleted rows (we don't want controls showing if there is only one visibile row, but many deleted rows)
  rows() {
    const allRows = this.element.querySelectorAll(this.wrapperSelectorValue)
    return Array.from(allRows).filter((item) => item.querySelector("input[name*='_destroy']").value != "1")
  }

  get count() {
    return this.rows().length
  }

  getItemForButton(button) {
    return button.closest(this.wrapperSelectorValue)
  }

}