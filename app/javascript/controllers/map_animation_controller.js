import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pin", "map"]

  connect() {
    // Listen for place highlight events from typewriter controller
    this.element.addEventListener("typewriter:place-highlighted", (event) => {
      this.highlightPin(event.detail.placeId)
    })

    this.element.addEventListener("typewriter:reset-pins", () => {
      this.resetPins()
    })
  }

  highlightPin(placeId) {
    const pin = this.pinTargets.find((p) => p.dataset.place === placeId)

    if (pin) {
      // Animate pin appearance
      pin.classList.remove("opacity-0")
      pin.classList.add("opacity-100", "animate-bounce")

      // Remove bounce animation after it completes
      setTimeout(() => {
        pin.classList.remove("animate-bounce")
      }, 1000)
    }
  }

  resetPins() {
    this.pinTargets.forEach((pin) => {
      pin.classList.remove("opacity-100", "animate-bounce")
      pin.classList.add("opacity-0")
    })
  }
}
