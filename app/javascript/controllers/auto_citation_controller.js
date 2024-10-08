import { Controller } from '@hotwired/stimulus'

const PURL_PLACE_HOLDER = ':link will be inserted here automatically when available:'
const DOI_PLACE_HOLDER = ':DOI will be inserted here automatically when available:'

export default class extends Controller {
  static targets = ['titleField', 'manual', 'auto', 'switch',
    'contributorFirst', 'contributorLast', 'contributorRole', 'contributorOrg',
    'embargoYear', 'embargo', 'userVersionYes']

  static values = {
    userVersion: Number, // user version stored in the work version record
    workVersionState: String, // work version state needed for handling the initial draft of a version differently from a saved draft where the user has previously made a version selection
    updatedUserVersion: Number // used for tracking user version changes during draft editing and avoiding over-incrementing the user version value
  }

  connect () {
    this.purl = this.data.get('purl') || PURL_PLACE_HOLDER // Use a real purl on a persisted item or a placeholder
    this.doi = this.data.get('doi') || ''
    if ((this.workVersionStateValue === 'deposited') || (this.workVersionStateValue === 'new')) { // initial draft version
      this.populateDisplay()
    } else if (this.version === 1) {
      this.autoTarget.value = this.citation // in review workflow before first deposit
    } else {
      this.autoTarget.value = this.currentUserVersion // use the incoming user version value as previously selected
    }

    // If the manualTarget is blank or the autoTarget matches the citation, then display the auto.
    const showAuto = this.enableAutoCitation()
    this.switchTarget.checked = showAuto
    this.displayDefault(showAuto)
  }

  populateDisplay () { // initial state before selections
    // Keep manualTarget in sync with autoTarget if manualTarget has not been manually changed.
    const manualValue = this.manualTarget.value.replace(PURL_PLACE_HOLDER, this.purl).replace(DOI_PLACE_HOLDER, this.doi)
    if (manualValue === this.citation) {
      this.manualTarget.value = this.citation
    }
    // initial citation value reflects current user version value because no selection made yet
    this.autoTarget.value = this.citation
  }

  // Update the autogenerated citation as new version selections change
  updateDisplay () {
    if ((this.workVersionStateValue === 'deposited') || (this.workVersionStateValue === 'new')) { // this is a new version draft with initial user version value
      this.autoTarget.value = this.citation
      const manualValue = this.manualTarget.value.replace(PURL_PLACE_HOLDER, this.purl).replace(DOI_PLACE_HOLDER, this.doi)
      if (manualValue === this.citation) {
        this.manualTarget.value = this.citation
      }
    } else { // this is a version draft and user version value may have already been changed
      if (this.hasUserVersionYesTarget && this.userVersionYesTarget.checked) {
        this.autoTarget.value = this.increaseUserVersion
      } else {
        this.autoTarget.value = this.decreaseUserVersion
      }
    }
  }

  // Update non-version information in the citation and keep manual citation in sync
  updateCitationInfo () {
    const manualValue = this.manualTarget.value.replace(PURL_PLACE_HOLDER, this.purl).replace(DOI_PLACE_HOLDER, this.doi)
    if (manualValue === this.autoTarget.value) {
      this.manualTarget.value = this.updatedCitation
    }
    this.autoTarget.value = this.updatedCitation
  }

  enableAutoCitation () {
    if (this.manualTarget.value === '') { // The initial value
      return true
    } else {
      const manualValue = this.manualTarget.value.replace(PURL_PLACE_HOLDER, this.purl).replace(DOI_PLACE_HOLDER, this.doi)
      if (manualValue === this.autoTarget.value) { // The user hasn't changed the manual citation
        return true
      }
    }
    return false
  }

  get citation () {
    return `${this.authorAsSentence} (${this.date}). ${this.title}.${this.versionClause} Stanford Digital Repository. Available at ${this.purl}${this.purlVersion}.${this.doiClause}`
  }

  // when non-version info changed, update citation and include the correct user version value at that time
  get updatedCitation () {
    if (this.updatedUserVersionValue > 0) {
      return this.updatedVersionCitation
    } else {
      return `${this.authorAsSentence} (${this.date}). ${this.title}. Version ${this.userVersionValue}. Stanford Digital Repository. Available at ${this.purl}${this.purlVersion}.${this.doiClause}`
    }
  }

  // citation with updated user version value
  get updatedVersionCitation () {
    return `${this.authorAsSentence} (${this.date}). ${this.title}. Version ${this.updatedUserVersionValue}. Stanford Digital Repository. Available at ${this.purl}/version/${this.updatedUserVersionValue}.${this.doiClause}`
  }

  get increaseUserVersion () { // Yes was selected
    if (this.updatedUserVersionValue > 0) { // the incoming userVersionValue is no longer valid because version selections have changed
      this.updatedUserVersionValue = this.updatedUserVersionValue + 1
    } else {
      this.updatedUserVersionValue = this.userVersionValue + 1
    }
    return this.updatedVersionCitation
  }

  get decreaseUserVersion () { // No was selected
    if (this.updatedUserVersionValue > 0) { // the incoming userVersionValue is no longer valid because version selections have changed
      this.updatedUserVersionValue = this.updatedUserVersionValue - 1
    } else {
      this.updatedUserVersionValue = this.userVersionValue - 1
    }
    return this.updatedVersionCitation
  }

  // citation with user version value
  get currentUserVersion () {
    return `${this.authorAsSentence} (${this.date}). ${this.title}. Version ${this.userVersionValue}. Stanford Digital Repository. Available at ${this.purl}/version/${this.userVersionValue}.${this.doiClause}`
  }

  get authorAsSentence () {
    switch (this.authors.length) {
      case 1:
      case 2:
        return this.authors.join(' and ')
      default:
        return `${this.authors.slice(0, -1).join(', ')}, and ${this.authors.slice(-1)}`
    }
  }

  // Authors (person and organization) as an array of strings.
  get authors () {
    return this.contributorRoles.map((roleField, index) => {
      if (roleField.attributes['data-contributors-target'].value === 'selectPersonRole') {
        const firstInitial = `${this.contributorFirsts[index].value.charAt(0)}.`
        const surname = this.contributorLasts[index].value
        return `${surname}, ${firstInitial}`
      }
      return this.contributorOrgNames[index].value
    })
  }

  get contributorRoles () {
    return this.contributorRoleTargets.filter(elem => elem.disabled === false)
  }

  get contributorOrgNames () {
    return this.contributorOrgTargets.filter(elem => elem.disabled === false)
  }

  get contributorFirsts () {
    return this.contributorFirstTargets.filter(elem => elem.disabled === false)
  }

  get contributorLasts () {
    return this.contributorLastTargets.filter(elem => elem.disabled === false)
  }

  get version () {
    if (this.hasUserVersionYesTarget && this.userVersionYesTarget.checked) {
      return this.userVersionValue + 1
    }
    return this.userVersionValue
  }

  get purlVersion () {
    return `/version/${this.version}`
  }

  get versionClause () {
    return ` Version ${this.version}.`
  }

  get doiClause () {
    if (this.doi === '') {
      return ''
    }
    return ` ${this.doi}`
  }

  // Triggered when the switch is toggled
  switchChanged (e) {
    this.displayDefault(e.target.checked)
  }

  // When true is passed, shows autogenerated, otherwise shows manual
  // It they switch back to autogenerated, clear out the manual field.
  displayDefault (showAutoGenerated) {
    this.manualTarget.hidden = showAutoGenerated
    this.autoTarget.hidden = !showAutoGenerated
    if (!showAutoGenerated) {
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

  get title () {
    return this.titleFieldTarget.value
  }

  get embargoYear () {
    if (this.hasEmbargoTarget && this.embargoTarget.checked) {
      return this.embargoYearTarget.value
    }
    return null
  }

  get date () {
    const date = new Date()
    if (this.embargoYear) {
      date.setYear(this.embargoYear)
    }
    return `${date.getFullYear()}`
  }
}
