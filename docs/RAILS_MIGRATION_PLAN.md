# Carnet de Voyage - Rails Migration Plan

## Framework Recommendation: Ruby on Rails

Given everything you've told me, I strongly recommend **Ruby on Rails** over Next.js. Here's why:

---

## Why Rails is Perfect for Your SaaS

### 1. Complex Data Model (Rails shines here)

```ruby
# Your data relationships in Rails:
User
  - has_many :maps (as creator)
  - has_many :collaborations
  - has_many :followers
  - has_many :following

Map
  - belongs_to :creator (User)
  - has_many :places
  - has_many :collaborators
  - has_many :likes
  - has_many :comments
  - enum privacy: [:public, :private, :shared]

Place
  - belongs_to :map
  - has_many :photos

Follow
  - belongs_to :follower (User)
  - belongs_to :followed (User)

# Rails scaffolding generates all this in minutes
```

### 2. Authentication & Authorization (Built-in)

- **Devise** for user auth (signup, login, password reset)
- **Pundit** for permissions (who can edit which map)
- Free tier limits (3-5 maps) → Simple validation
- B2B vs Consumer tiers → Easy role management

### 3. Background Jobs (Critical for AI)

```ruby
# OpenAI extraction can take 5-30 seconds
# Don't make users wait!

class ExtractPlacesJob < ApplicationJob
  def perform(map_id, text)
    # Call OpenAI API
    # Call Geocoding API
    # Save places to database
    # Notify user via Action Cable (real-time update)
  end
end

# User gets instant feedback, processing happens in background
```

### 4. PDF Export (Built-in)

```ruby
# PDF generation for travel planners
gem 'prawn' # or 'wicked_pdf'

class MapPdfExporter
  def generate(map)
    pdf = Prawn::Document.new
    # Add map title, places, mini-map screenshot
    pdf.render_file("trip_#{map.id}.pdf")
  end
end

# Much easier than Next.js (needs external service)
```

### 5. File Uploads (Photos)

```ruby
# ActiveStorage handles it
class Map < ApplicationRecord
  has_one_attached :cover_image
end

# Automatic S3/CloudFront integration
# Image resizing, variants (thumbnail, medium, large)
```

### 6. Internationalization (i18n built-in)

```ruby
# config/locales/en.yml
en:
  maps:
    create: "Create Map"

# config/locales/fr.yml
fr:
  maps:
    create: "Créer une Carte"

# config/locales/ja.yml
ja:
  maps:
    create: "地図を作成"

# Rails handles this automatically
```

### 7. Admin Dashboard (Free with Rails)

```ruby
# Add ActiveAdmin or Avo
gem 'avo'

# Get beautiful admin panel to:
# - Manage users
# - View all maps
# - Monitor B2B accounts
# - Track revenue
# - See analytics
```

### 8. Subscription & Payments

```ruby
# Stripe integration for B2B tiers
gem 'pay' # or 'stripe-rails'

class User < ApplicationRecord
  pay_customer

  def can_create_map?
    return true if subscribed? # B2B or Paid
    maps.count < 5 # Free tier limit
  end
end
```

### 9. Speed of Development

- Rails conventions = faster coding
- Gems for everything (PDF, payments, auth, jobs, uploads)
- Less "glue code" to write
- Admin dashboard for free

---

## Next.js vs Rails Comparison

| Feature | Next.js Setup | Rails Setup |
|---------|---------------|-------------|
| **Auth** | NextAuth/Clerk (complex) | Devise (5 min) |
| **Database** | Prisma + setup | ActiveRecord (built-in) |
| **File uploads** | Uploadthing/S3 SDK | ActiveStorage |
| **Background jobs** | Inngest/Trigger.dev ($$$) | Sidekiq (free) |
| **PDF export** | Puppeteer/external API | Prawn gem |
| **Admin panel** | Build from scratch | ActiveAdmin/Avo |
| **Payments** | Stripe SDK | Pay gem |
| **i18n** | next-i18next setup | Built-in |
| **Permissions** | Custom RBAC | Pundit gem |

**Next.js = 20+ libraries to integrate**
**Rails = 5 gems, mostly built-in**

---

## Rails Migration & Implementation Plan

### **Phase 1: Setup & Foundation (Week 1)**

#### 1.1 Create New Rails App

```bash
# Install Rails (if not already)
gem install rails

# Create new Rails 7 app with everything we need
rails new carnet-de-voyage \
  --database=postgresql \
  --css=tailwind \
  --javascript=esbuild \
  --skip-test  # We'll use RSpec later

cd carnet-de-voyage
```

#### 1.2 Essential Gems

```ruby
# Gemfile additions:

# Authentication
gem 'devise'

# Authorization
gem 'pundit'

# Background Jobs
gem 'sidekiq'

# File Uploads
gem 'image_processing'  # For ActiveStorage variants

# API Clients
gem 'ruby-openai'       # OpenAI integration
gem 'httparty'          # For Mapbox/Geoapify API

# Frontend (Hotwire stack)
gem 'turbo-rails'       # Already included in Rails 7
gem 'stimulus-rails'    # Already included in Rails 7

# PDF Generation (for travel planners)
gem 'prawn'
gem 'prawn-table'

# Payments (for B2B tier)
gem 'pay'
gem 'stripe'

# Admin Dashboard
gem 'avo'  # Modern, beautiful admin panel

# Translations
# i18n is built-in, just add locale files

group :development do
  gem 'annotate'  # Add schema comments to models
  gem 'bullet'    # Detect N+1 queries
end
```

#### 1.3 Database Schema Design

```ruby
# This is what we'll generate with migrations

# Users table
create_table :users do |t|
  t.string :email, null: false
  t.string :username, null: false
  t.string :encrypted_password
  t.integer :role, default: 0  # 0: free, 1: paid, 2: b2b
  t.integer :maps_limit, default: 5
  t.timestamps
end

# Maps table
create_table :maps do |t|
  t.string :title, null: false
  t.text :description
  t.string :destination  # e.g., "New York City, USA"
  t.integer :privacy, default: 0  # 0: public, 1: private, 2: shared
  t.integer :places_count, default: 0
  t.text :original_text  # User's pasted text/notes
  t.text :processed_text # HTML with highlighted places
  t.references :creator, foreign_key: { to_table: :users }
  t.timestamps
end

# Places table
create_table :places do |t|
  t.string :name, null: false
  t.decimal :latitude, precision: 10, scale: 6
  t.decimal :longitude, precision: 10, scale: 6
  t.string :address
  t.string :place_type  # restaurant, bar, museum, etc.
  t.string :emoji       # 🍺, 🍽️, 🏛️
  t.text :context       # AI-extracted description
  t.integer :position   # Order in the list
  t.references :map, foreign_key: true
  t.timestamps
end

# Map Tags (hashtags)
create_table :tags do |t|
  t.string :name, null: false, index: { unique: true }
  t.integer :maps_count, default: 0
  t.timestamps
end

create_table :map_tags do |t|
  t.references :map, foreign_key: true
  t.references :tag, foreign_key: true
  t.timestamps
end

# Collaborations
create_table :collaborations do |t|
  t.references :map, foreign_key: true
  t.references :user, foreign_key: true
  t.integer :role, default: 0  # 0: viewer, 1: editor
  t.timestamps
end

# Follows
create_table :follows do |t|
  t.integer :follower_id, null: false
  t.integer :followed_id, null: false
  t.timestamps
end

# Likes
create_table :likes do |t|
  t.references :user, foreign_key: true
  t.references :map, foreign_key: true
  t.timestamps
end

# Comments
create_table :comments do |t|
  t.text :body, null: false
  t.references :user, foreign_key: true
  t.references :map, foreign_key: true
  t.timestamps
end
```

---

### **Phase 2: Core Features Migration (Week 2-3)**

#### 2.1 Migrate Current MVP Logic

**Your Current Flow (Next.js):**
1. User pastes text → POST /api/extract-places → OpenAI
2. Get places → POST /api/geocode → Mapbox/Geoapify
3. Display map + highlighted text

**New Rails Flow:**
1. User pastes text → POST /maps → Sidekiq job
2. Job calls OpenAI + Geocoding (background)
3. Real-time update via Turbo Streams
4. Map appears live as places are extracted

**Code Structure:**

```ruby
# app/controllers/maps_controller.rb
class MapsController < ApplicationController
  def create
    @map = current_user.maps.new(map_params)

    if current_user.can_create_map?
      if @map.save
        # Process in background
        ExtractPlacesJob.perform_later(@map.id)

        # Respond with Turbo Stream for real-time update
        render turbo_stream: turbo_stream.append(
          "maps",
          partial: "maps/map_processing",
          locals: { map: @map }
        )
      end
    else
      flash[:error] = "Upgrade to create more maps"
      redirect_to pricing_path
    end
  end
end

# app/jobs/extract_places_job.rb
class ExtractPlacesJob < ApplicationJob
  def perform(map_id)
    map = Map.find(map_id)

    # Step 1: Extract places with OpenAI
    extractor = OpenAIPlaceExtractor.new(map.original_text)
    result = extractor.extract

    # Step 2: Geocode places
    result[:places].each do |place_data|
      geocoder = GeocodeService.new(place_data[:name], map.destination)
      coords = geocoder.geocode

      map.places.create!(
        name: place_data[:name],
        latitude: coords[:lat],
        longitude: coords[:lng],
        context: place_data[:context],
        place_type: place_data[:type],
        emoji: determine_emoji(place_data[:type])
      )
    end

    # Step 3: Create highlighted text
    map.update!(
      processed_text: create_highlighted_text(map.original_text, map.places),
      destination: result[:destination]
    )

    # Step 4: Broadcast update via Turbo Stream
    Turbo::StreamsChannel.broadcast_replace_to(
      "map_#{map.id}",
      target: "map_#{map.id}",
      partial: "maps/map",
      locals: { map: map }
    )
  end
end

# app/services/openai_place_extractor.rb
class OpenAIPlaceExtractor
  def initialize(text)
    @text = text
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def extract
    # Same logic as your current /api/extract-places/route.ts
    # Returns { places: [...], destination: "..." }
  end
end

# app/services/geocode_service.rb
class GeocodeService
  def initialize(place_name, destination = nil)
    @place_name = place_name
    @destination = destination
  end

  def geocode
    # Same logic as your current /api/geocode/route.ts
    # Try Geoapify first, fallback to Mapbox
  end
end
```

#### 2.2 Frontend with Hotwire

**View Structure:**

```erb
<!-- app/views/maps/new.html.erb -->
<div class="flex h-screen">
  <!-- Left Panel -->
  <div class="w-2/5 bg-white">
    <h1>Carnet de Voyage</h1>

    <%= form_with model: @map, data: { turbo: true } do |f| %>
      <%= f.text_area :original_text,
          placeholder: "Paste your travel notes...",
          class: "w-full h-full" %>

      <%= f.submit "Extract & Map Places" %>
    <% end %>
  </div>

  <!-- Right Panel - Map -->
  <div class="w-3/5">
    <turbo-frame id="map_<%= @map.id %>">
      <!-- Map loads here via Turbo Stream -->
    </turbo-frame>
  </div>
</div>
```

**Stimulus Controller for Mapbox:**

```javascript
// app/javascript/controllers/mapbox_controller.js
import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

export default class extends Controller {
  static values = { places: Array }

  connect() {
    this.map = new mapboxgl.Map({
      container: this.element,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [-74.006, 40.7128],
      zoom: 12
    })

    this.addMarkers()
  }

  addMarkers() {
    this.placesValue.forEach(place => {
      // Same marker logic as your current Map.tsx
      const el = document.createElement('div')
      el.innerHTML = place.emoji

      new mapboxgl.Marker(el)
        .setLngLat([place.longitude, place.latitude])
        .addTo(this.map)
    })
  }
}
```

**Map Partial:**

```erb
<!-- app/views/maps/_map.html.erb -->
<div data-controller="mapbox"
     data-mapbox-places-value="<%= @map.places.to_json %>"
     class="w-full h-full">
  <!-- Mapbox GL JS map renders here -->
</div>
```

---

### **Phase 3: Authentication & Authorization (Week 3)**

#### 3.1 Install and Configure Devise

```bash
# Install Devise
rails generate devise:install
rails generate devise User
rails generate devise:views

# Add role to users
rails generate migration AddRoleToUsers role:integer maps_limit:integer
```

#### 3.2 User Model

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :maps, foreign_key: :creator_id, dependent: :destroy
  has_many :collaborations, dependent: :destroy
  has_many :collaborative_maps, through: :collaborations, source: :map

  enum role: { free: 0, paid: 1, b2b: 2 }

  def can_create_map?
    b2b? || paid? || maps.count < maps_limit
  end
end
```

#### 3.3 Install and Configure Pundit

```bash
# Install Pundit
rails generate pundit:install
```

```ruby
# app/policies/map_policy.rb
class MapPolicy < ApplicationPolicy
  def show?
    record.public? ||
    record.creator == user ||
    record.collaborators.include?(user)
  end

  def update?
    record.creator == user ||
    record.collaborations.where(user: user, role: 'editor').exists?
  end

  def destroy?
    record.creator == user
  end
end
```

#### 3.4 Controller with Authorization

```ruby
# app/controllers/maps_controller.rb
class MapsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_map, only: [:show, :edit, :update, :destroy]

  def show
    authorize @map
  end

  def update
    authorize @map
    if @map.update(map_params)
      redirect_to @map, notice: 'Map updated successfully'
    else
      render :edit
    end
  end

  private

  def set_map
    @map = Map.find(params[:id])
  end
end
```

---

### **Phase 4: Social Features (Week 4)**

#### 4.1 Homepage Feed

```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @maps = Map.includes(:creator, :tags, cover_image_attachment: :blob)
                .where(privacy: :public)
                .order(created_at: :desc)
                .page(params[:page])
                .per(12)
  end
end
```

```erb
<!-- app/views/home/index.html.erb -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  <% @maps.each do |map| %>
    <%= render 'maps/card', map: map %>
  <% end %>
</div>

<!-- app/views/maps/_card.html.erb -->
<div class="relative overflow-hidden rounded-lg shadow-lg">
  <%= image_tag map.cover_image, class: "w-full h-64 object-cover" %>

  <div class="absolute top-4 right-4 bg-black/70 text-white px-3 py-1 rounded">
    <%= map.places_count %> places
  </div>

  <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/90 to-transparent p-6">
    <h3 class="text-white text-xl font-bold mb-2"><%= map.title %></h3>

    <div class="flex flex-wrap gap-2 mb-3">
      <% map.tags.limit(5).each do |tag| %>
        <span class="text-xs text-white/90">#<%= tag.name %></span>
      <% end %>
    </div>

    <div class="flex items-center justify-between">
      <%= link_to "View", map_path(map), class: "text-blue-400" %>
      <span class="text-white/70 text-sm">@<%= map.creator.username %></span>
    </div>
  </div>
</div>
```

#### 4.2 Search by Tags

```ruby
# app/controllers/tags_controller.rb
class TagsController < ApplicationController
  def show
    @tag = Tag.find_by!(name: params[:id])
    @maps = @tag.maps
                .includes(:creator, :cover_image_attachment)
                .where(privacy: :public)
                .page(params[:page])
  end
end
```

#### 4.3 Follow System

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # ... existing code ...

  has_many :following_relationships, class_name: 'Follow',
           foreign_key: :follower_id, dependent: :destroy
  has_many :following, through: :following_relationships,
           source: :followed

  has_many :follower_relationships, class_name: 'Follow',
           foreign_key: :followed_id, dependent: :destroy
  has_many :followers, through: :follower_relationships,
           source: :follower

  def following?(other_user)
    following.include?(other_user)
  end

  def follow(other_user)
    following_relationships.create(followed: other_user)
  end

  def unfollow(other_user)
    following_relationships.find_by(followed: other_user)&.destroy
  end
end

# app/models/follow.rb
class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'

  validates :follower_id, uniqueness: { scope: :followed_id }
  validates :follower_id, comparison: { other_than: :followed_id }
end
```

#### 4.4 Likes

```ruby
# app/models/like.rb
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :map, counter_cache: true

  validates :user_id, uniqueness: { scope: :map_id }
end

# app/models/map.rb
class Map < ApplicationRecord
  # ... existing code ...
  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user

  def liked_by?(user)
    likers.include?(user)
  end
end

# app/controllers/likes_controller.rb
class LikesController < ApplicationController
  before_action :authenticate_user!

  def create
    @map = Map.find(params[:map_id])
    @map.likes.create(user: current_user)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @map }
    end
  end

  def destroy
    @like = current_user.likes.find(params[:id])
    @map = @like.map
    @like.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @map }
    end
  end
end
```

#### 4.5 Comments

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :map, counter_cache: true

  validates :body, presence: true
end

# app/models/map.rb
class Map < ApplicationRecord
  # ... existing code ...
  has_many :comments, dependent: :destroy
end

# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @map = Map.find(params[:map_id])
    @comment = @map.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @map }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
```

---

### **Phase 5: B2B Features (Week 5)**

#### 5.1 Subscription with Stripe

```bash
# Install Pay gem
bundle add pay
rails pay:install:migrations
rails db:migrate
```

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # ... existing code ...
  pay_customer

  def can_create_map?
    return true if active_subscription?
    maps.count < maps_limit
  end

  def active_subscription?
    payment_processor&.subscribed?
  end
end

# config/initializers/pay.rb
Pay.setup do |config|
  config.business_name = "Carnet de Voyage"
  config.business_address = "123 Street, City, Country"
  config.support_email = "support@carnetdevoyage.com"
end
```

#### 5.2 PDF Export

```ruby
# app/services/map_pdf_generator.rb
class MapPdfGenerator
  def initialize(map)
    @map = map
    @pdf = Prawn::Document.new
  end

  def generate
    # Header
    @pdf.text @map.title, size: 24, style: :bold, align: :center
    @pdf.move_down 10
    @pdf.text "Destination: #{@map.destination}", size: 14, align: :center
    @pdf.move_down 20

    # Places list
    @map.places.each_with_index do |place, index|
      @pdf.text "#{index + 1}. #{place.emoji} #{place.name}", size: 14, style: :bold
      @pdf.text "   #{place.address}", size: 10, color: '666666' if place.address

      if place.context.present?
        @pdf.text "   #{place.context}", size: 9, color: '444444'
      end

      @pdf.move_down 15
    end

    @pdf.start_new_page

    # Add map screenshot (using Mapbox Static Images API)
    @pdf.text "Map Overview", size: 18, style: :bold
    @pdf.move_down 10

    map_image = download_map_screenshot
    @pdf.image map_image, fit: [500, 400], position: :center

    # Footer
    @pdf.move_down 20
    @pdf.text "Generated by Carnet de Voyage", size: 8, align: :center, color: '999999'
    @pdf.text "#{Time.current.strftime('%B %d, %Y')}", size: 8, align: :center, color: '999999'

    @pdf.render
  end

  private

  def download_map_screenshot
    # Use Mapbox Static Images API
    # https://docs.mapbox.com/api/maps/static-images/

    # Calculate map bounds from places
    lngs = @map.places.pluck(:longitude)
    lats = @map.places.pluck(:latitude)

    # Build Mapbox Static API URL with markers
    markers = @map.places.map do |place|
      "pin-s+ff0000(#{place.longitude},#{place.latitude})"
    end.join(',')

    url = "https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/#{markers}/auto/600x400@2x"
    url += "?access_token=#{ENV['MAPBOX_TOKEN']}"

    # Download and return image
    URI.open(url)
  end
end

# app/controllers/maps_controller.rb
class MapsController < ApplicationController
  # ... existing code ...

  def export_pdf
    @map = Map.find(params[:id])
    authorize @map, :export?

    pdf = MapPdfGenerator.new(@map).generate

    send_data pdf,
              filename: "#{@map.title.parameterize}.pdf",
              type: 'application/pdf',
              disposition: 'attachment'
  end
end

# app/policies/map_policy.rb
class MapPolicy < ApplicationPolicy
  # ... existing code ...

  def export?
    user&.b2b? && (record.creator == user || record.shared_with?(user))
  end
end
```

#### 5.3 Share Private Maps with Clients

```ruby
# app/models/map.rb
class Map < ApplicationRecord
  # ... existing code ...

  def share_with(user, role: :viewer)
    collaborations.create(user: user, role: role)
  end

  def shared_with?(user)
    collaborators.include?(user)
  end

  def generate_share_link
    # Generate a secure token for sharing
    update(share_token: SecureRandom.urlsafe_base64(32))
    share_token
  end
end

# Add migration for share_token
# rails g migration AddShareTokenToMaps share_token:string
# add_index :maps, :share_token, unique: true

# app/controllers/maps_controller.rb
class MapsController < ApplicationController
  def show
    @map = Map.find_by(id: params[:id]) ||
           Map.find_by(share_token: params[:id])

    authorize @map
  end

  def share
    @map = Map.find(params[:id])
    authorize @map

    if params[:user_email]
      user = User.find_by(email: params[:user_email])
      @map.share_with(user) if user
    end

    @share_link = map_url(@map.generate_share_link)
  end
end
```

#### 5.4 Admin Dashboard with Avo

```bash
# Install Avo
bundle add avo
rails generate avo:install
```

```ruby
# config/initializers/avo.rb
Avo.configure do |config|
  config.root_path = '/admin'
  config.app_name = 'Carnet de Voyage Admin'
  config.license = 'community' # or 'pro' if you have a license
end

# app/avo/resources/user_resource.rb
class UserResource < Avo::BaseResource
  self.title = :email
  self.includes = []

  field :id, as: :id
  field :email, as: :text
  field :username, as: :text
  field :role, as: :select, enum: ::User.roles
  field :maps_limit, as: :number
  field :maps, as: :has_many
  field :created_at, as: :date_time
end

# app/avo/resources/map_resource.rb
class MapResource < Avo::BaseResource
  self.title = :title
  self.includes = [:creator, :places, :tags]

  field :id, as: :id
  field :title, as: :text
  field :destination, as: :text
  field :privacy, as: :select, enum: ::Map.privacies
  field :places_count, as: :number
  field :creator, as: :belongs_to
  field :places, as: :has_many
  field :tags, as: :has_many
  field :created_at, as: :date_time

  action TogglePrivacy
  action ExportPdf
end
```

---

### **Phase 6: Deployment (Week 6)**

#### 6.1 Deployment Options

**Recommended: Render.com** (Easy, Free Tier, PostgreSQL + Redis included)

**Alternative Options:**
- Fly.io (Fast, Global, Docker-based)
- Heroku (Classic, Easy, but more expensive)
- Railway (Modern, Simple)

#### 6.2 Render Configuration

```yaml
# render.yaml
services:
  # Web Server
  - type: web
    name: carnet-de-voyage
    env: ruby
    buildCommand: "./bin/render-build.sh"
    startCommand: "bundle exec puma -C config/puma.rb"
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: carnet-de-voyage-db
          property: connectionString
      - key: REDIS_URL
        fromService:
          name: carnet-de-voyage-redis
          type: redis
          property: connectionString
      - key: RAILS_MASTER_KEY
        sync: false
      - key: OPENAI_API_KEY
        sync: false
      - key: MAPBOX_TOKEN
        sync: false
      - key: GEOAPIFY_API_KEY
        sync: false
      - key: STRIPE_SECRET_KEY
        sync: false

  # Background Worker (Sidekiq)
  - type: worker
    name: carnet-de-voyage-worker
    env: ruby
    buildCommand: "./bin/render-build.sh"
    startCommand: "bundle exec sidekiq -C config/sidekiq.yml"
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: carnet-de-voyage-db
          property: connectionString
      - key: REDIS_URL
        fromService:
          name: carnet-de-voyage-redis
          type: redis
          property: connectionString
      - key: RAILS_MASTER_KEY
        sync: false
      - key: OPENAI_API_KEY
        sync: false
      - key: MAPBOX_TOKEN
        sync: false
      - key: GEOAPIFY_API_KEY
        sync: false

databases:
  - name: carnet-de-voyage-db
    databaseName: carnet_de_voyage
    user: carnet_de_voyage
    plan: starter  # Free tier

services:
  - type: redis
    name: carnet-de-voyage-redis
    plan: starter  # Free tier
    ipAllowList: []
```

#### 6.3 Build Script

```bash
#!/usr/bin/env bash
# bin/render-build.sh

set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate
```

#### 6.4 Production Configuration

```ruby
# config/environments/production.rb
Rails.application.configure do
  # ... existing config ...

  # Active Storage (for file uploads)
  config.active_storage.service = :amazon

  # Action Cable (for real-time updates)
  config.action_cable.url = 'wss://carnet-de-voyage.onrender.com/cable'
  config.action_cable.allowed_request_origins = [
    'https://carnet-de-voyage.onrender.com'
  ]
end

# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  region: <%= ENV['AWS_REGION'] %>
  bucket: <%= ENV['AWS_BUCKET'] %>
```

#### 6.5 Sidekiq Configuration

```yaml
# config/sidekiq.yml
:concurrency: 5
:queues:
  - default
  - mailers
  - active_storage_analysis
  - active_storage_purge

production:
  :concurrency: 10
```

```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] }
end
```

---

## MVP Feature Priority

### Must Have (Launch Day - Week 1-3)

1. ✅ User signup/login (Devise)
2. ✅ Create map from textarea (AI extraction)
3. ✅ Public homepage feed with map cards
4. ✅ Map detail page with interactive Mapbox
5. ✅ Privacy controls (public/private)
6. ✅ Free tier limit (5 maps)
7. ✅ Hashtag system
8. ✅ Cover image (auto from first place)

### Phase 2 (Week 4 - Post Launch)

9. ✅ Follow users
10. ✅ Like maps
11. ✅ Comments
12. ✅ Search by tags/location

### Phase 3 (Week 5-6 - B2B Features)

13. ✅ Paid tiers (Stripe)
14. ✅ Share private maps with clients
15. ✅ PDF export
16. ✅ Admin dashboard

### Later (Based on Feedback)

- Time/feasibility calculator
- Itinerary day organization
- Mobile app (React Native)
- Collaboration features (real-time editing)
- Photo uploads for places
- Route optimization
- Budget tracking
- Export to Google Maps
- Integration with booking platforms

---

## Technology Stack Summary

### Backend
- **Framework:** Ruby on Rails 7
- **Database:** PostgreSQL
- **Cache/Jobs:** Redis + Sidekiq
- **Authentication:** Devise
- **Authorization:** Pundit
- **File Storage:** ActiveStorage + S3
- **Payments:** Stripe (via Pay gem)
- **PDF Generation:** Prawn

### Frontend
- **Framework:** Hotwire (Turbo + Stimulus)
- **CSS:** Tailwind CSS
- **Maps:** Mapbox GL JS
- **JavaScript:** ESBuild

### APIs & Services
- **AI:** OpenAI GPT-4
- **Geocoding:** Geoapify + Mapbox
- **Email:** (Choose: SendGrid, Postmark, AWS SES)
- **Monitoring:** (Choose: Honeybadger, Sentry, Rollbar)

### Deployment
- **Hosting:** Render.com (or Fly.io/Heroku)
- **CI/CD:** GitHub Actions
- **CDN:** CloudFront (for ActiveStorage)

---

## Estimated Timeline

| Phase | Duration | Description |
|-------|----------|-------------|
| **Setup** | 1 week | Rails app, database, gems, basic structure |
| **Core MVP** | 2 weeks | AI extraction, maps, authentication |
| **Social Features** | 1 week | Following, likes, comments, feed |
| **B2B Features** | 2 weeks | Payments, PDF export, sharing |
| **Deployment** | 1 week | Production setup, testing, launch |
| **Total** | **6-8 weeks** | From zero to launched SaaS |

---

## Cost Estimation (Monthly)

### Free Tier (For Testing)
- Render.com: $0 (with limitations)
- PostgreSQL: $0 (512MB)
- Redis: $0 (25MB)
- Total: **$0/month**

### Production (Small Scale - 100 users)
- Render.com Web Server: $7/month
- Render.com Worker: $7/month
- PostgreSQL: $7/month
- Redis: $7/month
- AWS S3: ~$5/month
- OpenAI API: ~$20-50/month (depends on usage)
- Mapbox: $0 (50k requests free)
- Stripe: 2.9% + 30¢ per transaction
- Total: **~$60-90/month**

### Production (Medium Scale - 1000 users)
- Render.com: $25/month (scaled)
- Database: $25/month
- S3 + CDN: $20/month
- OpenAI: $200-500/month
- Total: **~$300-600/month**

---

## Next Steps

1. **Create Rails App** - Run the setup commands
2. **Database Schema** - Create migrations for all tables
3. **Core Models** - Set up User, Map, Place associations
4. **Authentication** - Install Devise
5. **AI Integration** - Port OpenAI extraction logic
6. **Frontend** - Build with Hotwire + Stimulus
7. **Deploy** - Get it live on Render.com
8. **Iterate** - Add features based on user feedback

---

## Resources for Learning

### Rails Fundamentals
- [Rails Guides](https://guides.rubyonrails.org/) - Official documentation
- [GoRails](https://gorails.com/) - Video tutorials
- [Rails Tutorial](https://www.railstutorial.org/) - Complete book

### Hotwire
- [Hotwire Handbook](https://hotwired.dev/) - Official docs
- [Turbo Rails Tutorial](https://www.hotrails.dev/) - Step-by-step guide

### Deployment
- [Render Rails Guide](https://render.com/docs/deploy-rails)
- [Fly.io Rails Guide](https://fly.io/docs/rails/)

---

## Questions?

This plan covers everything from architecture to deployment. The key advantages of Rails for your SaaS are:

1. **Speed of development** - 6-8 weeks vs 12-16 weeks with Next.js
2. **Built-in features** - Auth, jobs, uploads, i18n all included
3. **Cost efficiency** - Fewer external services needed
4. **Scalability** - Can handle thousands of users easily
5. **Maintainability** - Convention over configuration

Ready to start building? 🚀
