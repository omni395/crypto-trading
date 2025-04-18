// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"
import InstrumentsSearchController from "./instruments_search_controller"
import InstrumentsController from "./instruments_controller"

application.register("instruments-search", InstrumentsSearchController)
application.register("instruments", InstrumentsController)