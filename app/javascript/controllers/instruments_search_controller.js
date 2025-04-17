import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = {
    turboFrame: String,
    minLength: { type: Number, default: 2 }
  }

  connect() {
    this.timeout = null
  }

  search(event) {
    const value = event.target.value.trim()
    if (value.length < this.minLengthValue) return
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const form = this.element.closest("form")
      if (form) {
        form.requestSubmit()
      }
    }, 250)
  }
}
