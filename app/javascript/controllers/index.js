import { Application } from "stimulus"
import { Autocomplete } from 'stimulus-autocomplete'
import { definitions } from 'stimulus:./controllers'

const app = Application.start()
application.load(definitions)

application.register('autocomplete', Autocomplete)
