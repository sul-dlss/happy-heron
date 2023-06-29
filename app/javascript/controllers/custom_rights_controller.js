import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["customRightsConfigFieldset", "noIncludeCustomRightsRadioButton", "yesIncludeCustomRightsRadioButton",
                    "customRightsSourceIsCollectionButton", "customRightsSourceIsDepositorButton", "customRightsInstructionsFieldset"]

  connect() {
    this.updateChooseCustomRightsFieldsetEnabled()
    this.updateCustomRightsInstructionsFieldsetEnabled()
  }

  updateChooseCustomRightsFieldsetEnabled() {
    this.customRightsConfigFieldsetTarget.hidden = !this.yesIncludeCustomRightsRadioButtonTarget.checked
    this.customRightsConfigFieldsetTarget.disabled = !this.yesIncludeCustomRightsRadioButtonTarget.checked
  }

  updateCustomRightsInstructionsFieldsetEnabled() {
    this.customRightsInstructionsFieldsetTarget.hidden = !this.customRightsSourceIsDepositorButtonTarget.checked
    this.customRightsInstructionsFieldsetTarget.disabled = !this.customRightsSourceIsDepositorButtonTarget.checked
  }
}
