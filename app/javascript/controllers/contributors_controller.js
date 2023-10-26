import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['person', 'organization', 'personName', 'personNameSelect', 'personOrcid', 'personOrcidName', 'orcid',
    'orcidFeedback', 'orcidFirstName', 'orcidLastName', 'orcidDisplayName', 'selectPersonRole', 'selectOrganizationRole',
    'contributorTypePerson', 'contributorTypeOrganization']

  static values = { required: Boolean }

  connect () {
    this.contributorTypeChanged()
    this.personChanged()
    if (this.hasValidOrcid) {
      this.lookupOrcid()
    }
  }

  contributorTypeChanged () {
    if (this.contributorTypePersonTarget.checked) {
      this.selectPersonRoleTarget.hidden = false
      this.selectPersonRoleTarget.disabled = false
      this.selectOrganizationRoleTarget.hidden = true
      this.selectOrganizationRoleTarget.disabled = true
      this.displayPerson()
    } else {
      this.selectPersonRoleTarget.hidden = true
      this.selectPersonRoleTarget.disabled = true
      this.selectOrganizationRoleTarget.hidden = false
      this.selectOrganizationRoleTarget.disabled = false
      this.displayOrganization()
    }
  }

  // Person radio button toggled.
  personChanged () {
    if (this.isPersonNameSelected) { this.displayPersonName() } else { this.displayPersonOrcid() }
  }

  // Person is displayed and name radio button selected.
  displayPersonName () {
    // Name displayed.
    this.personNameTarget.querySelectorAll('input[type="text"],input[type="hidden"]').forEach((element) => {
      element.disabled = false
    })

    // ORCID inputs disabled and cleared
    this.personOrcidTarget.querySelectorAll('input[type="text"]').forEach((element) => {
      element.disabled = true
      element.value = ''
    })

    this.orcidTarget.value = 'https://orcid.org/'

    // Name part of ORCID form hidden.
    this.personOrcidNameTarget.hidden = true
  }

  // Person is displayed and ORCID radio button selected.
  displayPersonOrcid () {
    // ORCID displayed.
    this.personOrcidTarget.querySelectorAll('input[type="text"]').forEach((element) => {
      element.disabled = false
      element.readOnly = false
    })
    // this.personOrcidNameTarget.hidden = false

    // Name inputs disabled and cleared.
    this.personNameTarget.querySelectorAll('input[type="text"],input[type="hidden"]').forEach((element) => {
      element.disabled = true
      element.value = ''
    })
  }

  // Organization role is selected.
  displayOrganization () {
    this.organizationTarget.hidden = false
    if (this.requiredValue) {
      this.organizationTarget.querySelectorAll('input[type="text"]:not(.affiliation-input)').forEach((element) => {
        element.required = true
      })
    }

    this.personTarget.hidden = true
    this.personTarget.querySelectorAll('input[type="text"]:not(.affiliation-input),input[type="hidden"]:not(.affiliation-input)').forEach((element) => {
      element.required = false
      element.value = ''
    })
  }

  // Person role is selected.
  displayPerson () {
    this.personTarget.hidden = false
    if (this.requiredValue) {
      this.personTarget.querySelectorAll('input[type="text"]:not(.affiliation-input)').forEach((element) => {
        element.required = true
      })
    }

    this.organizationTarget.hidden = true
    this.organizationTarget.querySelectorAll('input[type="text"]:not(.affiliation-input)').forEach((element) => {
      element.required = false
      element.value = ''
    })
  }

  get hasValidOrcid () {
    return /^https:\/\/(.*\.)?orcid\.org\/\d{4}-\d{4}-\d{4}-[0-9X]{4}$/.test(this.orcidTarget.value)
  }

  get isPersonNameSelected () {
    return this.personNameSelectTarget.checked
  }

  lookupOrcid () {
    if (this.hasValidOrcid) {
      // Freeze it so that user can't change.
      this.clearOrcidError()
      this.orcidTarget.readOnly = true
      this.performLookup()
    } else {
      this.showOrcidError('ORCID iD must be formatted as "https://orcid.org/XXXX-XXXX-XXXX-XXXX"')
    }
  }

  clearOrcidError () {
    this.orcidFeedbackTarget.innerText = 'You must provide an ORCID iD'
    this.orcidTarget.classList.remove('is-invalid')
    this.orcidTarget.setCustomValidity('')
    this.orcidTarget.readOnly = false
  }

  showOrcidError (error) {
    this.orcidTarget.readOnly = false
    this.orcidFeedbackTarget.innerText = error
    this.orcidTarget.classList.add('is-invalid')
    this.orcidTarget.setCustomValidity(error)
  }

  // Displays name retrieved for ORCID.
  showOrcidName (firstName, lastName) {
    this.orcidTarget.readOnly = true
    if (this.orcidFirstNameTarget.value === '') this.orcidFirstNameTarget.value = firstName
    if (this.orcidLastNameTarget.value === '') this.orcidLastNameTarget.value = lastName
    this.orcidDisplayNameTarget.innerText = `Name associated with this ORCID iD is ${firstName} ${lastName}.`
    this.personOrcidNameTarget.hidden = false
    // So that citation is updated.
    this.orcidLastNameTarget.dispatchEvent(new Event('change'))
  }

  remove () {
    this.selectPersonRoleTarget.disabled = true
    this.selectOrganizationRoleTarget.disabled = true
    this.organizationTarget.querySelectorAll('input[type="text"]').forEach((element) => {
      element.disabled = true
    })
    this.personTarget.querySelectorAll('input[type="text"]').forEach((element) => {
      element.disabled = true
    })
  }

  performLookup () {
    fetch('/orcid?id=' + this.orcidTarget.value)
      .then(response => {
        if (!response.ok) throw new Error(response.status)
        return response.json()
      })
      .then(data => {
        this.showOrcidName(data.first_name, data.last_name)
      })
      .catch(error => {
        if (error.message === '404') {
          this.showOrcidError('ORCID iD not found')
        } else {
          this.showOrcidError('Error validating ORCID iD. Please clear and try again.')
        }
      })
  }
}
