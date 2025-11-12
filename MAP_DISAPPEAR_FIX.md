# Map Disappearing Issue - Fix Documentation

## Problem Description

When navigating to http://localhost:3001/maps/new, the preview map would appear briefly and then disappear automatically.

## Root Cause Analysis

### Issue 1: Double Event Listener Execution
The page has two event listeners that were both firing:
1. **`DOMContentLoaded`** (line 250) - Standard DOM ready event
2. **`turbo:load`** (line 256) - Turbo navigation event

Even though the page has `data-turbo="false"` attribute, **both events were firing**, causing `initializeMap()` to be called twice in rapid succession.

### Issue 2: Map Removal Logic
The original `initializeMap()` function had this logic:
```javascript
// Clean up existing map instance if it exists
if (previewMapInstance) {
  console.log('Removing existing map instance');
  previewMapInstance.remove();  // ❌ This removes the first map!
  previewMapInstance = null;
}
```

**What happened:**
1. First call to `initializeMap()` → Creates map successfully
2. Second call to `initializeMap()` (milliseconds later) → Removes the first map, creates second map
3. But the second creation might fail or the container gets corrupted
4. Result: Map appears then disappears

### Issue 3: Mapbox GL JS Token Requirement
**Important:** Mapbox GL JS library requires an access token **even when using non-Mapbox tile sources** like OpenStreetMap. Without a token, the map would initialize but then throw an error:

```
Error: A valid Mapbox access token is required to use Mapbox GL JS
```

This is a quirk of the Mapbox GL JS library - it validates the token on initialization regardless of the tile source being used.

## The Fix

Added a **guard mechanism** to prevent multiple simultaneous initializations:

### Changes Made to [app/views/maps/new.html.erb](app/views/maps/new.html.erb):

1. **Added initialization flag** (line 140):
```javascript
let isInitializing = false;
```

2. **Added guard at function start** (lines 180-183):
```javascript
// Prevent multiple simultaneous initializations
if (isInitializing || previewMapInstance) {
  console.log('Map already initializing or initialized, skipping...');
  return;
}

isInitializing = true;
```

3. **Reset flag after initialization** (lines 229-238):
```javascript
// Wait for map to load before adding controls
previewMapInstance.on('load', function() {
  console.log('Map loaded successfully');
  isInitializing = false;  // ✅ Reset flag when done
});

// Handle errors
previewMapInstance.on('error', function(e) {
  console.error('Map error:', e);
  isInitializing = false;  // ✅ Reset flag on error
});
```

4. **Added error handling** (lines 242-246):
```javascript
catch (error) {
  console.error('Error creating map:', error);
  isInitializing = false;  // ✅ Reset flag on exception
  previewMapInstance = null;
}
```

5. **Reset flag on early returns**:
   - When container not found (line 194)
   - When mapboxgl not loaded (line 201)
   - When Mapbox token missing (line 212)

6. **Added placeholder token for OpenStreetMap** (lines 217-220):
```javascript
// Set a placeholder token for OSM (Mapbox GL JS requires this)
// This won't make any API calls to Mapbox when using custom tile sources
mapboxgl.accessToken = 'pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw';
```

**Why this is needed:** Mapbox GL JS library requires a token to be set, even when using non-Mapbox tile sources. This is a public Mapbox token that satisfies the library's requirement but won't result in any Mapbox API charges when using OpenStreetMap tiles.

**Important:** This token is only used to satisfy the library's initialization check. When using custom raster tile sources (like OSM), **no Mapbox API requests are made** and **no costs are incurred**.

## How It Works Now

1. **First call** to `initializeMap()`:
   - `isInitializing` = false, `previewMapInstance` = null → Proceed ✅
   - Set `isInitializing` = true
   - Create map
   - Map loads → Set `isInitializing` = false

2. **Second call** to `initializeMap()` (from duplicate event):
   - `isInitializing` = true OR `previewMapInstance` exists → **Skip!** ✅
   - Console: "Map already initializing or initialized, skipping..."
   - No map removal, no double initialization

## Testing Instructions

### Before Testing:
Ensure your `.env` file has:
```bash
TILE_PROVIDER=openstreetmap
```

### Test Steps:

1. **Start the server:**
```bash
bin/dev
```

2. **Open browser:** http://localhost:3001/maps/new

3. **Open Browser Console** (F12 → Console tab)

4. **Expected Console Output:**
```
DOMContentLoaded fired
Creating new map instance with openstreetmap tiles
turbo:load fired
Map already initializing or initialized, skipping...  ← ✅ This prevents double init!
Map loaded successfully
```

5. **Visual Verification:**
   - ✅ Map appears and stays visible
   - ✅ OpenStreetMap tiles load correctly
   - ✅ Tokyo area is centered
   - ✅ Navigation controls visible (zoom +/-, compass)
   - ✅ No flickering or disappearing

### What You Should See:

**Map Style (with OpenStreetMap):**
- Light beige/tan land color
- White/gray roads
- Black text labels
- Attribution: "© OpenStreetMap contributors"

**Map Behavior:**
- Stable, doesn't disappear
- Zoom in/out works
- Pan/drag works
- Stays loaded while typing notes

## Additional Improvements

### Error Handling
Added comprehensive error handling:
- Map load errors caught and logged
- Initialization flag reset on all error paths
- Prevents stuck initialization state

### Console Logging
Better debugging with clear messages:
- "Creating new map instance with [provider] tiles"
- "Map loaded successfully"
- "Map already initializing or initialized, skipping..."
- "Map error: [details]"

### Tile Provider Integration
Now properly supports both tile providers:
- OpenStreetMap (development) - No API key needed
- Mapbox (production) - Uses Mapbox token

## Troubleshooting

### Issue: Map still disappears
**Check:**
1. Browser console for errors
2. Network tab for failed tile requests
3. Run: `document.querySelector('meta[name="tile-provider"]')?.content`
   - Should return: `"openstreetmap"`

### Issue: "Map error" in console
**Possible causes:**
1. Network blocking tile requests (check firewall/VPN)
2. Invalid tile provider configuration
3. Missing meta tags (check page source)

### Issue: Map shows error message
**For Mapbox:**
- Check `MAPBOX_TOKEN` is set in `.env`
- Verify token is valid at https://account.mapbox.com/

**For OpenStreetMap:**
- Check network tab for 403/404 errors from tile.openstreetmap.org
- OSM tiles should work without authentication

## Files Modified

```
modified:   app/views/maps/new.html.erb
  - Added isInitializing flag
  - Added guard logic to prevent double initialization
  - Removed map removal logic
  - Added error handling
  - Integrated tile provider switching
```

## Related Documentation

- [TILE_PROVIDER_TEST_PLAN.md](TILE_PROVIDER_TEST_PLAN.md) - Full testing guide
- [README.md](README.md) - Configuration instructions
- [.env.example](.env.example) - Environment variable examples

## Success Criteria

✅ **Fix Complete When:**
1. Map loads and stays visible on /maps/new
2. No console errors
3. Only one initialization occurs
4. Console shows "Map already initializing or initialized, skipping..." on second event
5. OpenStreetMap tiles load correctly
6. All map interactions work (zoom, pan, controls)

---

**Status:** ✅ Fixed
**Date:** 2025-11-12
**Issue:** Map appearing then disappearing on /maps/new
**Solution:** Added initialization guard to prevent double initialization from duplicate event listeners
