import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import CheckboxSelectAll from 'stimulus-checkbox-select-all'
application.register("checkbox-select-all", CheckboxSelectAll)
