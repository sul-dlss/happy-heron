import { Application } from "@hotwired/stimulus"
import { Autocomplete } from 'stimulus-autocomplete'
import { definitions } from 'stimulus:./'

const application = Application.start()
application.load(definitions)

application.register('autocomplete', Autocomplete)
