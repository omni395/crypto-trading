import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loginTab", "registerTab", "resetTab", "loginContent", "registerContent", "resetContent"]

  connect() {
    this.showTab("login")
    this.bindResetLink()
  }

  showTab(tab) {
    this.loginTabTarget.classList.remove("bg-blue-600")
    this.loginTabTarget.classList.add("bg-gray-500")
    this.registerTabTarget.classList.remove("bg-blue-600")
    this.registerTabTarget.classList.add("bg-gray-500")
    this.resetTabTarget.classList.remove("bg-blue-600")
    this.resetTabTarget.classList.add("bg-gray-500")
    this.loginContentTarget.classList.add("hidden")
    this.registerContentTarget.classList.add("hidden")
    this.resetContentTarget.classList.add("hidden")

    if (tab === "login") {
      this.loginTabTarget.classList.add("bg-blue-600")
      this.loginTabTarget.classList.remove("bg-gray-500")
      this.loginContentTarget.classList.remove("hidden")
    } else if (tab === "register") {
      this.registerTabTarget.classList.add("bg-blue-600")
      this.registerTabTarget.classList.remove("bg-gray-500")
      this.registerContentTarget.classList.remove("hidden")
    } else if (tab === "reset") {
      this.resetTabTarget.classList.add("bg-blue-600")
      this.resetTabTarget.classList.remove("bg-gray-500")
      this.resetContentTarget.classList.remove("hidden")
    }
  }

  loginTabClicked() {
    this.showTab("login")
  }

  registerTabClicked() {
    this.showTab("register")
  }

  resetTabClicked() {
    this.showTab("reset")
  }

  bindResetLink() {
    const link = document.getElementById("open-reset-tab")
    if (link) {
      link.addEventListener("click", (e) => {
        e.preventDefault()
        this.showTab("reset")
      })
    }
  }
}
