import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="typewriter"
export default class extends Controller {
  static targets = ["text", "cursor", "noteContainer", "mapContainer"]
  static values = { text: String }

  connect() {
    this.currentIndex = 0
    this.places = [
      { name: "Tokyo Tower", start: 19, end: 30 },
      { name: "Sukiyabashi Jiro", start: 45, end: 60 },
      { name: "Shibuya Crossing", start: 70, end: 86 },
      { name: "Hamarikyu Garden", start: 101, end: 117 }
    ]
    this.isTyping = false

    // Start animation when scrolled into view
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.isTyping) {
          this.startAnimation()
        }
      })
    }, { threshold: 0.5 })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  async startAnimation() {
    this.isTyping = true

    // Phase 1: Type text (5-6 seconds total at ~50ms per char)
    await this.typeText()

    // Phase 2: Highlight places (1 second)
    await this.highlightPlaces()

    // Phase 3: Transition to map (2 seconds)
    await this.transitionToMap()

    // Wait 2 seconds then loop
    await this.sleep(2000)
    this.reset()
    this.isTyping = false

    // Auto-restart after reset
    setTimeout(() => {
      if (this.element) {
        this.startAnimation()
      }
    }, 500)
  }

  async typeText() {
    const text = this.textValue
    this.textTarget.textContent = ""

    for (let i = 0; i < text.length; i++) {
      this.textTarget.textContent += text[i]
      await this.sleep(50) // 50ms per character = ~5-6s total
    }

    // Keep cursor visible for a moment
    await this.sleep(500)
  }

  async highlightPlaces() {
    const fullText = this.textTarget.textContent
    let highlightedHTML = ""
    let lastIndex = 0

    // Highlight each place name with green background
    this.places.forEach(place => {
      // Add text before place
      highlightedHTML += fullText.substring(lastIndex, place.start)

      // Add highlighted place name
      const placeName = fullText.substring(place.start, place.end + 1)
      highlightedHTML += `<span class="bg-green-100 px-1 rounded transition-colors duration-300">${placeName}</span>`

      lastIndex = place.end + 1
    })

    // Add remaining text
    highlightedHTML += fullText.substring(lastIndex)

    // Update with highlights
    this.textTarget.innerHTML = highlightedHTML

    // Hide cursor during highlight phase
    this.cursorTarget.classList.add('opacity-0')

    await this.sleep(1000)
  }

  async transitionToMap() {
    // Fade out note container
    this.noteContainerTarget.classList.add('transition-opacity', 'duration-500')
    this.noteContainerTarget.classList.remove('opacity-100')
    this.noteContainerTarget.classList.add('opacity-0')

    await this.sleep(500)

    // Hide notes, show map
    this.noteContainerTarget.classList.add('hidden')
    this.mapContainerTarget.classList.remove('hidden')
    this.mapContainerTarget.classList.add('opacity-0', 'transition-opacity', 'duration-500')

    // Trigger reflow
    this.mapContainerTarget.offsetHeight

    // Fade in map
    this.mapContainerTarget.classList.remove('opacity-0')
    this.mapContainerTarget.classList.add('opacity-100')

    await this.sleep(1500)
  }

  reset() {
    // Reset text
    this.textTarget.textContent = ""
    this.textTarget.innerHTML = ""

    // Show cursor again
    this.cursorTarget.classList.remove('opacity-0')

    // Show notes, hide map
    this.noteContainerTarget.classList.remove('hidden', 'opacity-0')
    this.noteContainerTarget.classList.add('opacity-100')
    this.mapContainerTarget.classList.add('hidden')
    this.mapContainerTarget.classList.remove('opacity-100')

    this.currentIndex = 0
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}
