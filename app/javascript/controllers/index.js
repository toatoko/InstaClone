// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus" // Import Application directly from Stimulus

// Create and start the Stimulus application instance here
const application = Application.start()

// Configure Stimulus development experience
application.debug = true // Keep this true for debugging
window.Stimulus = application // Make the Stimulus application instance globally accessible

// Import and register individual controllers explicitly
import ThemeController from "controllers/theme_controller"
application.register("theme", ThemeController)

import ReportModalController from "controllers/report_modal_controller"
application.register("report-modal", ReportModalController)

import ReportButtonController from "controllers/report_button_controller" // NEW: Register the report-button controller
application.register("report-button", ReportButtonController)

// Eager load any other controllers in the 'controllers' directory
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
