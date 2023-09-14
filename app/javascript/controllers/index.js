import { Application } from "@hotwired/stimulus"
import { Autocomplete } from 'stimulus-autocomplete'
import NestedForm from 'stimulus-rails-nested-form'
import OrderedForm from './ordered_form_controller'
import { definitions } from 'stimulus:./'

const application = Application.start()
application.load(definitions)

application.register('autocomplete', Autocomplete)
application.register('author-form', OrderedForm)
application.register('contributor-form', NestedForm)
application.register('affiliation-form', NestedForm)
application.register('contact-email-form', NestedForm)

