import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"
import "mapbox-gl/dist/mapbox-gl.css"

export default class extends Controller {
  static values = {
    places: Array
  }

  connect() {
    console.log("Map controller connected!")
    console.log("Places data:", this.placesValue)
    console.log("Map element:", this.element)
    console.log("Map element dimensions:", this.element.offsetWidth, this.element.offsetHeight)

    // Get Mapbox token from meta tag (we'll add this to layout)
    const token = document.querySelector('meta[name="mapbox-token"]')?.content
    console.log("Mapbox token found:", !!token)

    if (!token) {
      console.error("Mapbox token not found")
      this.element.innerHTML = '<div class="flex items-center justify-center h-full text-gray-500">Map configuration error: Mapbox token not set</div>'
      return
    }

    mapboxgl.accessToken = token

    // Calculate center and bounds from places
    const places = this.placesValue

    if (!places || places.length === 0) {
      // Show a default map centered on a general location
      this.showDefaultMap()
      return
    }

    // Ensure the map container has proper dimensions
    if (this.element.offsetWidth === 0 || this.element.offsetHeight === 0) {
      console.warn("Map container has zero dimensions, waiting for layout...")
      setTimeout(() => this.initializeMap(), 100)
      return
    }

    this.initializeMap()
  }

  initializeMap() {
    const places = this.placesValue

    const bounds = new mapboxgl.LngLatBounds()
    places.forEach(place => {
      if (place.longitude && place.latitude) {
        bounds.extend([place.longitude, place.latitude])
      }
    })

    // Initialize map
    console.log("Creating map with bounds:", bounds)
    console.log("Container dimensions:", this.element.offsetWidth, this.element.offsetHeight)
    
    try {
      this.map = new mapboxgl.Map({
        container: this.element,
        style: 'mapbox://styles/mapbox/streets-v12',
        bounds: bounds,
        fitBoundsOptions: {
          padding: 50
        }
      })

      console.log("Map created successfully!")

      // Wait for map to load before adding controls and markers
      this.map.on('load', () => {
        console.log("Map loaded event fired")
        // Force resize in case container wasn't properly sized
        this.map.resize()
        this.addMarkers(places)
      })

      // Handle window resize
      window.addEventListener('resize', this.handleResize)

      // Add navigation controls
      this.map.addControl(new mapboxgl.NavigationControl(), 'top-right')
    } catch (error) {
      console.error("Error creating map:", error)
      this.element.innerHTML = `<div class="flex items-center justify-center h-full text-red-500">Error: ${error.message}</div>`
      return
    }
  }

  showDefaultMap() {
    try {
      this.map = new mapboxgl.Map({
        container: this.element,
        style: 'mapbox://styles/mapbox/streets-v12',
        center: [0, 20], // Default center
        zoom: 2
      })

      this.map.on('load', () => {
        this.map.resize()
      })

      this.map.addControl(new mapboxgl.NavigationControl(), 'top-right')
      
      // Show a message overlay
      this.element.innerHTML += '<div class="absolute top-4 left-4 bg-white bg-opacity-90 p-3 rounded-lg shadow-lg text-sm text-gray-600">No places to display on map</div>'
    } catch (error) {
      console.error("Error creating default map:", error)
      this.element.innerHTML = '<div class="flex items-center justify-center h-full text-gray-500 bg-gray-100 rounded-lg">Map unavailable</div>'
    }
  }

  addMarkers(places) {
    // Add markers for each place
    places.forEach((place, index) => {
      if (!place.longitude || !place.latitude) return

      // Create custom marker
      const el = document.createElement('div')
      el.className = 'custom-marker'
      el.style.backgroundColor = '#3B82F6'
      el.style.width = '30px'
      el.style.height = '30px'
      el.style.borderRadius = '50%'
      el.style.border = '3px solid white'
      el.style.boxShadow = '0 2px 4px rgba(0,0,0,0.3)'
      el.style.cursor = 'pointer'
      el.style.display = 'flex'
      el.style.alignItems = 'center'
      el.style.justifyContent = 'center'
      el.style.color = 'white'
      el.style.fontWeight = 'bold'
      el.style.fontSize = '12px'
      el.textContent = index + 1

      // Create popup
      const popup = new mapboxgl.Popup({ offset: 25 }).setHTML(`
        <div class="p-2">
          <h3 class="font-bold text-gray-900">${place.name}</h3>
          ${place.place_type ? `<span class="text-xs px-2 py-1 bg-blue-100 text-blue-800 rounded inline-block mt-1">${place.place_type}</span>` : ''}
          ${place.context ? `<p class="text-sm text-gray-600 mt-1">${place.context}</p>` : ''}
          ${place.address ? `<p class="text-xs text-gray-500 mt-1">${place.address}</p>` : ''}
        </div>
      `)

      // Add marker to map
      new mapboxgl.Marker(el)
        .setLngLat([place.longitude, place.latitude])
        .setPopup(popup)
        .addTo(this.map)
    })
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
    // Clean up resize listener
    window.removeEventListener('resize', this.handleResize)
  }

  handleResize = () => {
    if (this.map) {
      this.map.resize()
    }
  }
}
