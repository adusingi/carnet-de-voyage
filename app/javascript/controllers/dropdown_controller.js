import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close dropdown when clicking outside
    this.boundClose = this.closeOnClickOutside.bind(this)
  }

  toggle(event) {
    event.stopPropagation()

    if (this.menuTarget.style.display === "none") {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.style.display = "block"
    // Add click listener to close on outside click
    setTimeout(() => {
      document.addEventListener("click", this.boundClose)
    }, 0)
  }

  close() {
    this.menuTarget.style.display = "none"
    document.removeEventListener("click", this.boundClose)
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  rename(event) {
    event.preventDefault()
    this.close()

    const currentTitle = this.element.closest('.notes-panel').querySelector('h2').textContent.trim()
    const newTitle = prompt("Enter new title:", currentTitle)

    if (newTitle && newTitle !== currentTitle) {
      // Get the map ID from the URL or data attribute
      const mapId = window.location.pathname.split('/').pop()

      // Submit a form to update the title
      const form = document.createElement('form')
      form.method = 'POST'
      form.action = `/maps/${mapId}`

      const methodInput = document.createElement('input')
      methodInput.type = 'hidden'
      methodInput.name = '_method'
      methodInput.value = 'PATCH'
      form.appendChild(methodInput)

      const csrfToken = document.querySelector('meta[name="csrf-token"]').content
      const csrfInput = document.createElement('input')
      csrfInput.type = 'hidden'
      csrfInput.name = 'authenticity_token'
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)

      const titleInput = document.createElement('input')
      titleInput.type = 'hidden'
      titleInput.name = 'map[title]'
      titleInput.value = newTitle
      form.appendChild(titleInput)

      document.body.appendChild(form)
      form.submit()
    }
  }

  duplicate(event) {
    event.preventDefault()
    this.close()

    const mapId = window.location.pathname.split('/').pop()

    if (confirm("Do you want to duplicate this map?")) {
      // Submit a POST request to duplicate
      const form = document.createElement('form')
      form.method = 'POST'
      form.action = `/maps/${mapId}/duplicate`

      const csrfToken = document.querySelector('meta[name="csrf-token"]').content
      const csrfInput = document.createElement('input')
      csrfInput.type = 'hidden'
      csrfInput.name = 'authenticity_token'
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)

      document.body.appendChild(form)
      form.submit()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.boundClose)
  }
}
