# Carnet de Voyage - Homepage Design Document

**Date**: October 20, 2025
**Inspiration**: Tally.so, Notion.com
**Goal**: Create a beautiful, minimal landing page that feels like note-taking for travel planning

---

## 🎯 Design Objectives

1. **Simple & Clean**: Notion-like aesthetic with lots of white space
2. **Intuitive**: Immediately communicate the value proposition
3. **Engaging**: Animated demo that shows the magic of notes → maps
4. **Conversion-focused**: Clear CTAs, no friction (no signup to start)
5. **Professional yet warm**: Appeals to travel planners, geeks, and agencies

---

## 🎨 Visual Design System

### Color Palette

```css
/* Primary Colors */
--sky-blue: #0EA5E9;        /* CTA buttons, links, accents */
--warm-amber: #F59E0B;      /* Doodles, highlights, warmth */

/* Text Colors */
--text-primary: #1F2937;    /* Main headings, body text */
--text-secondary: #6B7280;  /* Subheadings, supporting text */

/* Backgrounds */
--bg-white: #FFFFFF;        /* Main background */
--bg-gray: #F9FAFB;         /* Alternate sections */

/* Borders & Dividers */
--border-gray: #E5E7EB;     /* Subtle borders */

/* Accents */
--success-green: #10B981;   /* Place highlights in demo */
```

### Typography

**Font Family**: Inter (Google Fonts)
- Weights: 400 (Regular), 500 (Medium), 700 (Bold), 800 (Extra Bold)

**Monospace**: JetBrains Mono (for code/note examples)
- Weight: 400

**Type Scale**:
```
Hero H1:        text-6xl (60px) font-extrabold
Section H2:     text-4xl (36px) font-bold
Card Title:     text-2xl (24px) font-semibold
Body Large:     text-xl (20px) font-normal
Body:           text-lg (18px) font-normal
Small:          text-sm (14px) font-normal
```

### Spacing & Layout

- **Max width**: 1200px (container)
- **Section padding**: py-24 (96px vertical)
- **Component spacing**: space-y-12 to space-y-16
- **Grid gaps**: gap-8 to gap-12

---

## 📐 Page Structure

### 1. Hero Section

**Layout**: Centered, full-width

**Elements**:
- Logo/Brand: "Carnet de Voyage" (top left, simple text)
- Navigation: Minimal (Sign In link top right)
- Headline: "The simplest way to turn travel notes into maps"
- Hand-drawn underline under "simplest" (magenta/amber)
- Subheadline: "Write naturally, visualize instantly. No complicated planning tools."
- CTA Button: "Start writing your trip →" (sky blue, rounded)
- Small text: "No signup required" (gray)
- Doodle elements: Notebook sketches, arrows, "Yes!" bubble (Tally-style)

**Spacing**:
- pt-20 (header)
- py-32 (content)
- Background: white

---

### 2. Animated Demo Section

**Layout**: Centered, max-w-5xl

**Animation Flow** (5-6 seconds total):
1. **Phase 1** (2s): Typewriter effect types out travel notes:
   ```
   Tomorrow I'll visit Tokyo Tower, eat sushi at
   Sukiyabashi Jiro, explore Shibuya Crossing,
   and relax at Hamarikyu Garden.
   ```
2. **Phase 2** (1s): Place names highlight in green
3. **Phase 3** (2s): Smooth fade/morph transition to map view
4. **Phase 4** (Loop): Map shows with 4 pins, gentle zoom animation

**Visual**:
- Container: Rounded card with subtle shadow
- Background: White card on gray background
- Border: 1px solid border-gray
- Note interface: Looks like a clean text editor
- Map: Mapbox with custom styling

**Technical**:
- Stimulus controller: `typewriter_controller.js`
- Auto-plays when scrolled into view
- Loops after 2s pause

---

### 3. Social Proof Section

**Layout**: 3-column grid, centered

**Title**: "Loved by travelers worldwide" (centered, h2)

**Testimonial Cards** (3 cards):

Card Structure:
```
┌─────────────────────────┐
│ "Quote text here..."    │
│                         │
│ [Avatar] Name           │
│          Role/Location  │
└─────────────────────────┘
```

**Placeholder Testimonials**:

1. **Sarah Chen** - Travel Blogger, San Francisco
   > "I used to spend hours with complicated planning apps. Now I just write my thoughts and boom - instant itinerary map. Game changer."

2. **Marcus Rodriguez** - Adventure Guide, Barcelona
   > "My clients love seeing their trip visually. I write the plan in plain English, share the map link, done. So simple."

3. **Emily Watson** - Digital Nomad, Bali
   > "Finally, a tool that matches how I actually plan trips - just jotting down ideas. The AI does the rest perfectly."

**Card Styling**:
- Background: white
- Border: 1px solid border-gray
- Padding: p-8
- Rounded: rounded-xl
- Shadow: shadow-sm hover:shadow-md
- Avatar: rounded-full, 48px
- Quote: Italic, text-gray-700
- Name: font-semibold
- Role: text-sm text-gray-500

---

### 4. Pricing Section

**Layout**: 3-column grid, centered

**Title**: "Simple pricing for everyone" (centered, h2)
**Subtitle**: "Start free, upgrade when you need more"

**Tiers**:

#### Free
- **Price**: $0/month
- **Tagline**: "Perfect for personal trips"
- **Features**:
  - ✓ 5 maps
  - ✓ AI place extraction
  - ✓ Interactive maps
  - ✓ Share with link
  - ✓ Export to Google Maps
- **CTA**: "Start free" (white button, border)

#### Paid ($9/month)
- **Price**: $9/month
- **Tagline**: "For frequent travelers"
- **Badge**: "Most Popular" (amber badge)
- **Features**:
  - ✓ Unlimited maps
  - ✓ PDF export
  - ✓ Private maps
  - ✓ Priority support
  - ✓ Custom branding (soon)
- **CTA**: "Start free trial" (sky blue button, primary)

#### B2B (Custom)
- **Price**: "Let's talk"
- **Tagline**: "For travel agencies & teams"
- **Features**:
  - ✓ Everything in Paid
  - ✓ Team collaboration
  - ✓ White-label options
  - ✓ API access
  - ✓ Dedicated support
- **CTA**: "Contact sales" (white button, border)

**Card Styling**:
- Background: white
- Border: 2px solid (border-gray for Free/B2B, sky-blue for Paid)
- Padding: p-8
- Rounded: rounded-2xl
- Most Popular badge: Absolute top-right, amber background
- Price: text-5xl font-bold
- Features: space-y-3, checkmarks in green

---

### 5. Final CTA Section

**Layout**: Centered, simple

**Elements**:
- Headline: "Ready to plan your next adventure?" (h2)
- Subheadline: "Start mapping your journey in seconds"
- CTA Button: "Start writing →" (large, sky blue)
- Small text: "No signup required"

**Styling**:
- Background: gradient from bg-gray to white
- py-24
- Text: centered

---

### 6. Footer

**Layout**: 3-column grid (left: brand, center: links, right: social)

**Content**:
- **Left**:
  - "Carnet de Voyage" (bold)
  - Tagline: "Turn travel notes into maps"

- **Center Links**:
  - About
  - Privacy Policy
  - Terms of Service
  - Contact

- **Right Social**:
  - GitHub icon
  - Twitter icon

- **Bottom**:
  - Copyright: "© 2025 Carnet de Voyage. All rights reserved."

**Styling**:
- Background: bg-gray
- Border-top: 1px solid border-gray
- py-12
- text-sm text-gray-600

---

## 🎭 Animations & Interactions

### Typewriter Animation
```javascript
// Stimulus controller: typewriter_controller.js
// 1. Type text character by character (50ms delay)
// 2. Highlight place names (green background, 300ms transition)
// 3. Fade out notes (500ms)
// 4. Fade in map (500ms)
// 5. Zoom map to fit all pins (1000ms)
// 6. Pause 2s, loop
```

### Micro-interactions
- **Buttons**: Scale on hover (scale-105), transition-all
- **Cards**: Shadow lift on hover (shadow-sm → shadow-lg)
- **Links**: Underline slide-in effect
- **Scroll**: Fade-in animation for sections (Intersection Observer)

---

## 🔧 Technical Implementation

### Routes
```ruby
# config/routes.rb
root 'home#index'
# Keep existing /maps routes for app
```

### Controller
```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    # Landing page - no authentication required
  end
end
```

### Views Structure
```
app/views/
├── home/
│   └── index.html.erb          # Landing page
├── layouts/
│   ├── application.html.erb    # App layout (existing)
│   └── landing.html.erb        # Landing page layout (new, minimal)
└── shared/
    ├── _landing_nav.html.erb   # Simple nav for landing
    └── _footer.html.erb        # Footer component
```

### Assets
```
app/javascript/
└── controllers/
    └── typewriter_controller.js  # Stimulus controller for animation

app/assets/images/
└── avatars/                      # Placeholder avatars for testimonials
```

---

## 📱 Responsive Design

### Breakpoints (Tailwind defaults)
- **Mobile**: < 640px (sm)
- **Tablet**: 640px - 1024px (md, lg)
- **Desktop**: > 1024px (xl, 2xl)

### Mobile Adjustments
- Hero H1: text-4xl on mobile, text-6xl on desktop
- Grids: 1 column on mobile, 3 columns on desktop
- Padding: py-12 on mobile, py-24 on desktop
- Demo: Full-width on mobile, max-w-5xl on desktop
- Doodles: Hide on mobile, show on desktop (hidden sm:block)

---

## ✅ Acceptance Criteria

- [ ] Hero section matches Tally's clean aesthetic
- [ ] Typewriter animation plays smoothly (5-6s loop)
- [ ] Place names highlight before transitioning to map
- [ ] All sections are responsive (mobile, tablet, desktop)
- [ ] CTAs are prominent and clear ("No signup required")
- [ ] Clicking "Start writing" goes to `/maps/new` (no auth required)
- [ ] Pricing cards clearly show features and CTAs
- [ ] Footer has all necessary links
- [ ] Page loads fast (< 2s)
- [ ] Animations don't block interaction

---

## 🚀 Next Steps

1. Create `HomeController` and route
2. Build landing layout (minimal, no app header)
3. Implement hero section with doodles
4. Create typewriter Stimulus controller
5. Build animated demo section
6. Add testimonials grid
7. Implement pricing cards
8. Add final CTA
9. Build footer
10. Test responsive design
11. Optimize performance

---

**Ready to build!** 🎨
