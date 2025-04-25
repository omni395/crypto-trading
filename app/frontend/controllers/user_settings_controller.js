import { Controller } from "@hotwired/stimulus"

// Контроллер для кнопок "По дефолту" и "Обновить монеты"
export default class extends Controller {
  static targets = [
    "defaultMarketType",
    "defaultQuoteAsset",
    "defaultStatus",
    "defaultExchange"
  ];

  resetToDefaults(event) {
    // TODO: Реализовать сброс всех select и input к дефолтным значениям
  }

  refreshCoins(event) {
    // TODO: Реализовать обновление списка монет (например, отправить GET-запрос или дернуть Turbo Frame)
  }
}
