#!/usr/bin/env ruby
# Verification script for tile provider configuration

puts "=" * 60
puts "Tile Provider Configuration Verification"
puts "=" * 60
puts

# Check Rails environment
rails_env = ENV['RAILS_ENV'] || 'development'
puts "🔹 Rails Environment: #{rails_env}"
puts

# Check TILE_PROVIDER setting
tile_provider = ENV['TILE_PROVIDER']
if tile_provider
  puts "🔹 TILE_PROVIDER: #{tile_provider} (explicitly set)"
else
  default = rails_env == 'production' ? 'mapbox' : 'openstreetmap'
  puts "🔹 TILE_PROVIDER: #{default} (default)"
  tile_provider = default
end
puts

# Check Mapbox token
mapbox_token = ENV['MAPBOX_TOKEN']
if mapbox_token && mapbox_token != ''
  puts "✅ MAPBOX_TOKEN: Set (#{mapbox_token[0..10]}...)"
else
  puts "⚠️  MAPBOX_TOKEN: Not set"
  if tile_provider == 'mapbox'
    puts "   ⚠️  WARNING: Using Mapbox tiles but token not found!"
  end
end
puts

# Configuration summary
puts "=" * 60
puts "Configuration Summary:"
puts "=" * 60

if tile_provider == 'openstreetmap'
  puts "✅ Using OpenStreetMap tiles (FREE)"
  puts "   - No API key required"
  puts "   - No API costs"
  puts "   - Ideal for development"
elsif tile_provider == 'mapbox'
  if mapbox_token && mapbox_token != ''
    puts "✅ Using Mapbox tiles (PREMIUM)"
    puts "   - API key found"
    puts "   - Usage will count towards Mapbox quota"
    puts "   - Recommended for production"
  else
    puts "❌ Configuration ERROR"
    puts "   - Mapbox tiles requested but no token found"
    puts "   - Maps will not load"
    puts "   - Set MAPBOX_TOKEN in .env file"
  end
end

puts "=" * 60
puts

# Testing instructions
puts "To test the configuration:"
puts "1. Start the server: bin/dev"
puts "2. Open http://localhost:3000"
puts "3. Create a new map at /maps/new"
puts "4. Check browser console for: 'Creating new map instance with #{tile_provider} tiles'"
puts
puts "To switch providers:"
puts "  Development (OSM): Add 'TILE_PROVIDER=openstreetmap' to .env"
puts "  Production (Mapbox): Add 'TILE_PROVIDER=mapbox' to .env"
puts
puts "Full test plan: See TILE_PROVIDER_TEST_PLAN.md"
puts "=" * 60
