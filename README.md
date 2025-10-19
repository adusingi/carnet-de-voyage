# Carnet de Voyage 🗺️

Transform your travel notes into interactive maps with AI-powered place extraction and multilingual support.

## ✨ Features

- 🤖 **AI-Powered Place Extraction** - Automatically extracts places, addresses, and landmarks from your travel notes using OpenAI GPT-4
- 🗺️ **Interactive Maps** - Visualize all extracted places on an interactive Mapbox map
- 🌍 **Multilingual Support** - Smart place name highlighting works across languages (e.g., English place names in French text)
- 🎯 **Smart Geocoding** - Accurate location detection using Google Maps Geocoding API with destination context
- ✨ **Intelligent Highlighting** - Place names in your notes are highlighted and clickable with:
  - Exact matching for special characters (handles "&", apostrophes, etc.)
  - Fuzzy matching for multilingual content
  - Core name extraction for flexible detection
- 📝 **Clean Interface** - NotePlan-inspired split-screen design for easy note-taking and map viewing
- ⚡ **Real-time Processing** - See your places extracted and mapped instantly

## 🚀 Demo

Simply paste your travel notes like:

```
Day 3 – TOKYO
Visit to Hamarikyu Garden, followed by a walk through the old Tsukiji fish market area.
Lunch of sushi. Afternoon at the Edo-Tokyo Museum to understand the city's origins.
Then, visit the Asakusa district and Tokyo's oldest temple, Senso-ji, walking along
the famous Nakamise street. End the day at the Shibuya Scramble observatory.
```

And Carnet de Voyage will:
1. Extract all 6 places
2. Geocode their coordinates
3. Display them on an interactive map
4. Highlight place names in your text

## 🛠️ Tech Stack

- **Backend**: Ruby on Rails 8.0
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Database**: PostgreSQL
- **Maps**: Mapbox GL JS
- **AI**: OpenAI GPT-4
- **Geocoding**: Google Maps Geocoding API

## 📋 Prerequisites

- Ruby 3.4.5
- PostgreSQL
- Node.js and npm (for JavaScript assets)
- API Keys:
  - OpenAI API key
  - Google Maps API key (with Geocoding API enabled)
  - Mapbox access token

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/adusingi/carnet-de-voyage.git
   cd carnet-de-voyage
   ```

2. **Install dependencies**
   ```bash
   bundle install
   npm install
   ```

3. **Set up environment variables**

   Create a `.env` file in the root directory:
   ```bash
   OPENAI_API_KEY=your_openai_api_key
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   MAPBOX_TOKEN=your_mapbox_token
   ```

4. **Set up the database**
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   ```

5. **Build assets**
   ```bash
   npm run build
   ```

6. **Start the server**
   ```bash
   bin/dev
   ```

7. **Visit the app**

   Open http://localhost:3000 in your browser

## 🔑 API Keys Setup

### OpenAI API Key
1. Sign up at https://platform.openai.com/
2. Create an API key in your account settings
3. Add to `.env` as `OPENAI_API_KEY`

### Google Maps API Key
1. Go to https://console.cloud.google.com/
2. Create a new project or select an existing one
3. Enable "Geocoding API"
4. Create credentials (API key)
5. Add to `.env` as `GOOGLE_MAPS_API_KEY`

### Mapbox Token
1. Sign up at https://www.mapbox.com/
2. Copy your default public token from your account page
3. Add to `.env` as `MAPBOX_TOKEN`

## 📁 Project Structure

```
carnet-de-voyage/
├── app/
│   ├── controllers/
│   │   └── maps_controller.rb      # Main controller for map CRUD
│   ├── models/
│   │   ├── map.rb                  # Map model with places association
│   │   └── place.rb                # Place model (geocoded locations)
│   ├── helpers/
│   │   └── maps_helper.rb          # Smart place name highlighting logic
│   ├── services/
│   │   ├── place_extractor.rb      # OpenAI integration for place extraction
│   │   └── place_geocoder.rb       # Google Maps geocoding service
│   ├── javascript/
│   │   └── controllers/
│   │       └── map_controller.js   # Stimulus controller for Mapbox
│   └── views/
│       └── maps/                   # Map views (index, show, edit, new)
├── db/
│   └── migrate/                    # Database migrations
└── package.json                    # JavaScript dependencies
```

## 🎨 Key Features Explained

### Smart Place Highlighting

The app uses a two-strategy approach for highlighting place names:

1. **Exact Matching**: Handles places with special characters like "The Up & Up" or "Mother's Ruin"
2. **Core Name Extraction**: Extracts proper nouns from place names to match multilingual text
   - "Hamarikyu Garden" (English) matches "jardin Hamarikyu" (French)
   - "Tsukiji Market" matches "marché de Tsukiji"

### Intelligent Place Extraction

Uses OpenAI GPT-4 to:
- Identify place names, addresses, and landmarks in natural language
- Detect the destination/city for better geocoding context
- Handle multiple languages and writing styles

### Contextual Geocoding

Google Maps Geocoding API with destination context ensures accurate results:
- "Senso-ji" with destination "Tokyo" → correct location in Japan
- Handles ambiguous place names by using trip context

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the MIT License.

## 🙏 Acknowledgments

- Inspired by [NotePlan](https://noteplan.co/) for the clean split-screen design
- Built with [Claude Code](https://claude.com/claude-code)

## 📧 Contact

Created by [@adusingi](https://github.com/adusingi)

---

**Note**: This app requires valid API keys for OpenAI, Google Maps, and Mapbox. API usage may incur costs depending on your usage volume.
