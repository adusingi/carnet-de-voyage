# Carnet de Voyage - Setup Complete! 🎉

Your carnet-de-voyage project has been successfully set up on this Mac!

## ✅ What's Been Installed

1. **Git Configuration**
   - Username: `adusingi`
   - Email: `aimabled@gmail.com`

2. **Development Tools**
   - Ruby 3.4.7 (via Homebrew)
   - Node.js 24.10.0
   - PostgreSQL 14.19 (running as service)
   - All Ruby dependencies (via bundle install)
   - All JavaScript dependencies (via npm install)

3. **Project Location**
   - Repository: `/Users/mac3jis/Documents/carnet-de-voyage`
   - GitHub: `https://github.com/adusingi/carnet-de-voyage`

## 🔑 Next Steps - API Keys Required

Before you can run the application, you need to add your API keys to the [.env](.env) file:

1. **OpenAI API Key**
   - Sign up at: https://platform.openai.com/
   - Get your API key from account settings
   - Add to `.env` file as: `OPENAI_API_KEY=your_key_here`

2. **Google Maps API Key**
   - Go to: https://console.cloud.google.com/
   - Create a project and enable "Geocoding API"
   - Create credentials (API key)
   - Add to `.env` file as: `GOOGLE_MAPS_API_KEY=your_key_here`

3. **Mapbox Token**
   - Sign up at: https://www.mapbox.com/
   - Copy your default public token
   - Add to `.env` file as: `MAPBOX_TOKEN=your_token_here`

## 🚀 How to Run the Application

Since this Mac has PATH issues in the current shell, you'll need to use full paths:

### Option 1: Set up the database (first time only)
```bash
cd /Users/mac3jis/Documents/carnet-de-voyage
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/opt/postgresql@14/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH" /opt/homebrew/opt/ruby/bin/bundle exec rails db:create
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/opt/postgresql@14/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH" /opt/homebrew/opt/ruby/bin/bundle exec rails db:migrate
```

### Option 2: Build assets
```bash
cd /Users/mac3jis/Documents/carnet-de-voyage
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH" /opt/homebrew/bin/npm run build
```

### Option 3: Start the development server
```bash
cd /Users/mac3jis/Documents/carnet-de-voyage
PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/opt/postgresql@14/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH" /opt/homebrew/opt/ruby/bin/bundle exec bin/dev
```

Then visit: http://localhost:3000

## 💡 Recommended: Fix PATH Permanently

To avoid using full paths every time, add this to your `~/.zshrc` file:

```bash
# Homebrew
export PATH="/opt/homebrew/bin:$PATH"

# Ruby
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# PostgreSQL
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
```

Then run: `source ~/.zshrc`

## 📚 Useful Commands

- **Check git status**: `cd /Users/mac3jis/Documents/carnet-de-voyage && /usr/bin/git status`
- **Pull latest changes**: `cd /Users/mac3jis/Documents/carnet-de-voyage && /usr/bin/git pull`
- **Push changes**: `cd /Users/mac3jis/Documents/carnet-de-voyage && /usr/bin/git push`

## 🔗 Links

- GitHub Repository: https://github.com/adusingi/carnet-de-voyage
- Project README: [README.md](README.md)
- Getting Started Guide: [GETTING_STARTED.md](GETTING_STARTED.md)

---

**Note**: PostgreSQL is running as a background service. If you need to stop/restart it:
- Stop: `/opt/homebrew/bin/brew services stop postgresql@14`
- Start: `/opt/homebrew/bin/brew services start postgresql@14`
- Restart: `/opt/homebrew/bin/brew services restart postgresql@14`
