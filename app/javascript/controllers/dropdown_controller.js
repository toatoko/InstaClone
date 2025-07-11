// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]
  
  connect() {
    // Close dropdown when clicking outside
    this.boundCloseOnOutsideClick = this.closeOnOutsideClick.bind(this)
    document.addEventListener("click", this.boundCloseOnOutsideClick)
  }
  
  disconnect() {
    document.removeEventListener("click", this.boundCloseOnOutsideClick)
  }
  
  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    // Close other dropdowns first
    document.querySelectorAll('[data-controller="dropdown"] [data-dropdown-target="menu"]').forEach(menu => {
      if (menu !== this.menuTarget) {
        menu.classList.add('hidden')
      }
    })
    
    // Toggle current dropdown
    this.menuTarget.classList.toggle('hidden')
  }
  
  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add('hidden')
    }
  }
}

