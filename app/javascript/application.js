import "@hotwired/turbo-rails"
import "controllers"
import Rails from "@rails/ujs"
Rails.start()
import Alpine from 'alpinejs'
window.Alpine = Alpine
Alpine.start()
