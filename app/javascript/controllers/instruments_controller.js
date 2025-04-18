import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    // this.refresh() // Удалено автообновление
  }

  // Метод ручного обновления списка инструментов
  refresh() {
    fetch(this.urlValue, { headers: { Accept: "text/vnd.turbo-stream.html" } })
      .then(r => r.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
