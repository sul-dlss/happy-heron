import { Application } from "stimulus"
import { Autocomplete } from 'stimulus-autocomplete'
import { definitions } from 'stimulus:./'

const application = Application.start()
application.load(definitions)

application.register('autocomplete', Autocomplete)
import DropzoneController from "./dropzone_controller"
application.register("dropzone2", DropzoneController)
