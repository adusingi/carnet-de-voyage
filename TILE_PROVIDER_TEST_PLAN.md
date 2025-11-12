# Tile Provider Testing Plan

## Overview
This document outlines the testing procedure for the OpenStreetMap (dev) / Mapbox (production) tile provider implementation.

## Implementation Summary

### Changes Made:
1. ✅ Added `TILE_PROVIDER` environment variable to `.env.example`
2. ✅ Updated [app/views/layouts/application.html.erb](app/views/layouts/application.html.erb#L8-L9) with conditional meta tags
3. ✅ Modified [app/javascript/controllers/map_controller.js](app/javascript/controllers/map_controller.js) to support both tile providers
4. ✅ Updated [app/views/maps/new.html.erb](app/views/maps/new.html.erb#L141-L223) preview map
5. ✅ Updated README.md with configuration instructions

### How It Works:
- **Environment Variable**: `TILE_PROVIDER` can be set to `openstreetmap` or `mapbox`
- **Default Behavior**:
  - If not set: Uses `openstreetmap` in development, `mapbox` in production
  - Meta tag in layout: `<meta name="tile-provider" content="...">`
- **JavaScript**: Reads meta tag and configures map accordingly
- **OpenStreetMap**: Uses free OSM raster tiles (no API key required)
- **Mapbox**: Uses Mapbox vector tiles with premium styling (requires API key)

### Important Note About Mapbox GL JS Token:
**Mapbox GL JS library requires a token even when using OpenStreetMap tiles.** This is a quirk of the library. We use a public placeholder token for OSM that satisfies the library's requirement but **does not result in any Mapbox API calls or costs** when using custom tile sources like OpenStreetMap.

---

## Test Plan

### Test 1: Development with OpenStreetMap (Default)

**Setup:**
```bash
# In your .env file
TILE_PROVIDER=openstreetmap
# Or omit TILE_PROVIDER entirely (defaults to OSM in development)
```

**Steps:**
1. Start the development server:
   ```bash
   bin/dev
   ```

2. Open browser and navigate to http://localhost:3000

3. Create a new map (click "Create New Map" or go to `/maps/new`)

4. **Verify Preview Map:**
   - Map should load on the right side (centered on Tokyo)
   - Open browser console (F12) and check for log: `"Creating new map instance with openstreetmap tiles"`
   - Map should show OpenStreetMap tiles (characteristic OSM styling)
   - No Mapbox API errors in console
   - Navigation controls should work (zoom in/out, rotate)

5. **Create a test map:**
   - Title: "Test OSM Map"
   - Notes:
     ```
     Paris, France
     Visit the Eiffel Tower and Arc de Triomphe
     ```
   - Click "Extract & Map Places"

6. **Verify Map Display Page:**
   - Should redirect to map show page with extracted places
   - Map should display with OpenStreetMap tiles
   - Place markers should appear correctly
   - Click markers to verify popups work
   - Verify place names are highlighted in the text on the left

7. **Check Browser Console:**
   - No errors related to Mapbox tokens
   - Should see: `"Creating new map instance with openstreetmap tiles"`

**Expected Results:**
- ✅ Maps load successfully with OSM tiles
- ✅ No Mapbox API calls (check Network tab in DevTools)
- ✅ Free OSM tiles are used
- ✅ All map functionality works (markers, popups, navigation)

---

### Test 2: Development with Mapbox

**Setup:**
```bash
# In your .env file
TILE_PROVIDER=mapbox
MAPBOX_TOKEN=your_actual_mapbox_token_here
```

**Steps:**
1. Restart the development server:
   ```bash
   bin/dev
   ```

2. Follow the same steps as Test 1

3. **Verify Map Styling:**
   - Map should show Mapbox premium tiles (Mapbox Streets style)
   - More polished, vector-based rendering
   - Smoother zoom transitions

**Expected Results:**
- ✅ Maps load with Mapbox premium styling
- ✅ Mapbox API calls visible in Network tab
- ✅ Console shows: `"Creating new map instance with mapbox tiles"`
- ✅ All functionality works

---

### Test 3: Production Configuration Verification

**Setup:**
```bash
# In production .env or environment variables
RAILS_ENV=production
TILE_PROVIDER=mapbox  # or omit (defaults to mapbox in production)
MAPBOX_TOKEN=your_production_mapbox_token
```

**Steps:**
1. Check that the application defaults to Mapbox in production:
   ```bash
   # Start Rails console in production mode
   RAILS_ENV=production rails console
   ```

2. In console, verify:
   ```ruby
   ENV['TILE_PROVIDER'] || (Rails.env.production? ? 'mapbox' : 'openstreetmap')
   # Should return 'mapbox'
   ```

**Expected Results:**
- ✅ Production defaults to Mapbox even without TILE_PROVIDER set
- ✅ Mapbox token is required in production

---

### Test 4: Edge Cases

**Test 4a: Missing TILE_PROVIDER (should use defaults)**
```bash
# Remove TILE_PROVIDER from .env
```
- Development should use OpenStreetMap
- Production should use Mapbox

**Test 4b: Invalid TILE_PROVIDER value**
```bash
TILE_PROVIDER=invalid_value
```
- Should default to OpenStreetMap (as it's not 'mapbox')

**Test 4c: Mapbox without token**
```bash
TILE_PROVIDER=mapbox
# Remove or comment out MAPBOX_TOKEN
```
- Should show error message: "Map configuration error: Mapbox token not set"

---

## Visual Verification Checklist

### OpenStreetMap Tiles Appearance:
- [ ] Simple, clean cartographic style
- [ ] Light beige/tan land color
- [ ] Roads in white/gray
- [ ] Labels in black text
- [ ] Attribution: "© OpenStreetMap contributors"

### Mapbox Tiles Appearance:
- [ ] More modern, vibrant styling
- [ ] Vector-based rendering (crisp at all zoom levels)
- [ ] Smooth zoom transitions
- [ ] Richer color palette
- [ ] 3D buildings at certain zoom levels
- [ ] Attribution: "© Mapbox © OpenStreetMap"

---

## Cost Verification

### OpenStreetMap (Development):
- **Cost**: $0 (completely free)
- **Limits**: Please follow [OSM Tile Usage Policy](https://operations.osmfoundation.org/policies/tiles/)
  - Max 2 requests/second per IP
  - Include valid User-Agent
  - Use for development only (not heavy production traffic)

### Mapbox (Production):
- **Cost**: Based on Mapbox pricing
  - First 50,000 loads/month free
  - Then $5 per 1,000 loads
- **Check usage**: https://account.mapbox.com/

---

## Troubleshooting

### Issue: Map not loading
**Check:**
1. Browser console for errors
2. Network tab for failed tile requests
3. Meta tags in page source (View Page Source → search for "tile-provider")

### Issue: Wrong tiles showing
**Check:**
1. `.env` file has correct `TILE_PROVIDER` value
2. Server was restarted after changing `.env`
3. Browser console shows correct log message

### Issue: Mapbox token error
**Check:**
1. `MAPBOX_TOKEN` is set in `.env`
2. Token is valid (test at https://account.mapbox.com/)
3. `TILE_PROVIDER=mapbox` is set

---

## Quick Verification Commands

```bash
# Check current environment variables
cat .env | grep TILE_PROVIDER

# Check if server is using correct provider (in browser console)
document.querySelector('meta[name="tile-provider"]')?.content

# Check Rails environment
rails runner "puts Rails.env"

# Verify default behavior
rails runner "puts ENV['TILE_PROVIDER'] || (Rails.env.production? ? 'mapbox' : 'openstreetmap')"
```

---

## Success Criteria

✅ **Implementation Complete When:**
1. Development uses OpenStreetMap by default (no Mapbox costs)
2. Production uses Mapbox by default (premium experience)
3. Both tile providers work correctly
4. No errors in browser console
5. All map features work (markers, popups, navigation)
6. Documentation is updated (README.md, .env.example)
7. Easy to switch between providers via environment variable

---

## Next Steps After Testing

1. **Development**: Use `TILE_PROVIDER=openstreetmap` in local `.env`
2. **Production**: Set `TILE_PROVIDER=mapbox` in production environment
3. **Deploy**: Push changes to production
4. **Monitor**: Check Mapbox usage dashboard to confirm production is using Mapbox
5. **Cost Savings**: Verify no Mapbox API calls during local development

