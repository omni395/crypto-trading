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
    const form = this.element.closest("form")
    if (value.length < this.minLengthValue) {
      // Если поле пустое или короткое, удаляем input name и отправляем форму для сброса фильтра
      if (form) {
        // Найти input с именем, удалить name, чтобы параметр не ушёл
        const input = form.querySelector('[name="q[symbol_or_base_asset_or_quote_asset_or_name_cont]"]')
        if (input) input.removeAttribute('name')
        form.requestSubmit()
      }
      return
    }
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      if (form) {
        // Вернуть name, если вдруг удалён
        const input = form.querySelector('[data-instruments-search-target="input"]')
        if (input && !input.hasAttribute('name')) {
          input.setAttribute('name', 'q[symbol_or_base_asset_or_quote_asset_or_name_cont]')
        }
        form.requestSubmit()
      }
    }, 250)
  }
}
