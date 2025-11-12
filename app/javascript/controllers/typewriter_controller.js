import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    this.places = ["tokyo-tower", "sukiyabashi-jiro", "shibuya-crossing", "hamarikyu-garden"]
    this.currentPlaceIndex = 0
    this.startAnimation()
  }

  startAnimation() {
    // Start the typewriter effect after a short delay
    setTimeout(() => {
      this.animatePlaces()
    }, 1000)
  }

  animatePlaces() {
    // Highlight each place sequentially
    const highlightPlace = (index) => {
      if (index >= this.places.length) {
        // Restart animation after all places are shown
        setTimeout(() => {
          this.resetHighlights()
          this.animatePlaces()
        }, 3000)
        return
      }

      const placeId = this.places[index]
      const placeElement = this.contentTarget.querySelector(`[data-place="${placeId}"]`)

      if (placeElement) {
        // Highlight the text
        placeElement.classList.add("bg-green-200", "text-green-900", "px-1", "rounded")

        // Trigger map pin animation
        this.dispatch("place-highlighted", { detail: { placeId } })

        // Move to next place after delay
        setTimeout(() => {
          highlightPlace(index + 1)
        }, 2000)
      }
    }

    highlightPlace(0)
  }

  resetHighlights() {
    const highlightedElements = this.contentTarget.querySelectorAll("[data-place]")
    highlightedElements.forEach((el) => {
      el.classList.remove("bg-green-200", "text-green-900", "px-1", "rounded")
    })

    // Reset map pins
    this.dispatch("reset-pins")
  }
}
