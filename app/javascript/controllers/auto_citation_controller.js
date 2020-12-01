import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["titleField", "manual", "auto", "switch",
    "contributorFirst", "contributorLast", "contributorRole", "contributorOrg",
    "year", "month", "day"];

  connect() {
    this.purl = this.data.get("purl") || ":link:" // Use a real purl on a persisted item or a placeholder

    this.updateDisplay()

    this.displayDefault(this.switchTarget.checked)
  }

  updateDisplay() {
    this.autoTarget.value = this.citation
  }

  get citation() {
    return `${this.authorAsSentence} (${this.date}). ${this.title}. Stanford Digital Repository. Available at ${this.purl}`
  }

  get authorAsSentence() {
    switch (this.authors.length){
      case 1:
      case 2:
        return this.authors.join(' and ')
      default:
        return `${this.authors.slice(0,-1).join(', ')}, and ${this.authors.slice(-1)}`
    }
  }

  get authors() {
    return this.contributorRoleTargets.map((roleField, index) => {
      if (roleField.value.startsWith('person')) {
        const firstInitial = `${this.contributorFirstTargets[index].value.charAt(0)}.`
        const surname = this.contributorLastTargets[index].value
        return `${surname}, ${firstInitial}`
      }
      return this.contributorOrgTargets[index].value
    })
  }

  switchChanged(e) {
    this.displayDefault(e.target.checked)
  }

  displayDefault(checked) {
    this.manualTarget.hidden = checked
    this.autoTarget.hidden = !checked
    if (!checked) {
      if (this.manualTarget.value === '') {
        // Copy the auto-generated value to the manual field
        this.manualTarget.value = this.citation
      }
    } else if (this.manualTarget.value === this.citation) {
      // Clear the manual field if they didn't make changes, so the auto field
      // can change, and then copy into the manual field the next time they flip the switch
      this.manualTarget.value = ''
    }
  }

  get title() {
    return this.titleFieldTarget.value
  }

  get year() {
    return this.yearTarget.value
  }

  get month() {
    return this.monthTarget.value
  }

  get day() {
    return this.dayTarget.value
  }

  get date() {
    const date = new Date();
    if (this.year) {
      date.setYear(this.year)
      if (this.month) {
        date.setMonth(this.month - 1)
        const month = date.toLocaleString('default', { month: 'long' });

        if (this.day) {
          date.setDate(this.day)
          return `${date.getFullYear()}, ${month} ${date.getDate()}`
        } else {
          return `${date.getFullYear()}, ${month}`
        }
      }
      return `${date.getFullYear()}`
    }
  }
}
