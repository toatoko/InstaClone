// app/javascript/controllers/index.js
import { application } from "controllers/application"
import ThemeController from "controllers/theme_controller"
application.register("theme", ThemeController)
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"

eagerLoadControllersFrom("controllers", application)