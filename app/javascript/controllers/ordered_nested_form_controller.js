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
    this.rows().forEach((_, index) => {
      this.filterButtons(index)
    })
  }

  setWeight(element, value) {
    element.querySelector("input[name*='weight']").value = value
  }

  filterButtons(index) {
    this.upButtonTargets[index].hidden = (index == 0)
    this.downButtonTargets[index].hidden = (index == this.count - 1)
  }

  renumber() {
    this.rows().forEach((row, index) => {
      this.setWeight(row, index)
      this.filterButtons(index)
    })
  }

  moveUp(event) {
    const item = this.getItemForButton(event.target)
    const previous = this.getPreviousSibling(item, 'div.contributor-row')
    previous.remove()
    item.insertAdjacentElement('afterend', previous)
    this.renumber()
  }

  moveDown(event) {
    const item = this.getItemForButton(event.target)
    const next = this.getNextSibling(item, 'div.contributor-row')
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

  // These methods help us find the next or previous element that also match a given selector.
  // This allows us to better target a specific element of interest.
  getNextSibling(elem, selector) {
    // Get the next sibling element
    // this is native JS: https://developer.mozilla.org/en-US/docs/Web/API/Element/nextElementSibling
    var sibling = elem.nextElementSibling

    // If there's no selector, return the sibling
    if (!selector) return sibling

    // If the sibling matches our selector, use it
    // If not, jump to the next sibling and continue the loop
    while (sibling) {
      if (sibling.matches(selector)) return sibling
      sibling = sibling.nextElementSibling
    }
  }

  getPreviousSibling(elem, selector) {
    // Get the previous sibling element
    // this is native JS: https://developer.mozilla.org/en-US/docs/Web/API/Element/previousElementSibling
    var sibling = elem.previousElementSibling

    // If there's no selector, return the sibling
    if (!selector) return sibling

    // If the sibling matches our selector, use it
    // If not, jump to the previous sibling and continue the loop
    while (sibling) {
      if (sibling.matches(selector)) return sibling
      sibling = sibling.previousElementSibling
    }
  }

}
