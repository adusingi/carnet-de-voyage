# Getting Started with Carnet de Voyage

## Quick Start

Your Rails app is ready to run! Follow these steps:

### 1. Start the Development Server

```bash
cd /Users/adusingi/Documents/carnet-de-voyage
bin/dev
```

This starts:
- Rails server on **http://localhost:3001**
- JavaScript build watcher
- CSS build watcher

**Note:** Port 3001 is used to avoid conflict with your Next.js project on port 3000.

### 2. Visit Your App

Open your browser and go to:
**http://localhost:3001**

You should see the Rails welcome page!

---

## What's Already Set Up

✅ Rails 8.0.3 with PostgreSQL
✅ Hotwire (Turbo + Stimulus)
✅ Tailwind CSS
✅ Authentication gems (Devise)
✅ Authorization (Pundit)
✅ OpenAI integration (ruby-openai)
✅ API clients (HTTParty)
✅ PDF generation (Prawn)
✅ Payments (Pay + Stripe)
✅ Admin dashboard (Avo)
✅ Environment variables (.env file)

---

## Run Both Projects Together

You can run your Next.js MVP and Rails SaaS side-by-side:

### Terminal 1 - Next.js (Reference)
```bash
cd /Users/adusingi/Documents/Noteplan
npm run dev
```
Visit: http://localhost:3000

### Terminal 2 - Rails (New SaaS)
```bash
cd /Users/adusingi/Documents/carnet-de-voyage
bin/dev
```
Visit: http://localhost:3001

---

## Next Steps

Now that your Rails app is running, you can start building features!

### Recommended Order:

1. **Set up authentication**
   ```bash
   bin/rails generate devise:install
   bin/rails generate devise User
   ```

2. **Create your first models**
   ```bash
   bin/rails generate model Map title:string destination:string
   bin/rails generate model Place name:string latitude:decimal longitude:decimal map:references
   ```

3. **Run migrations**
   ```bash
   bin/rails db:migrate
   ```

4. **Create controllers**
   ```bash
   bin/rails generate controller Home index
   bin/rails generate controller Maps index show new create
   ```

5. **Port your OpenAI logic** from Next.js

---

## Useful Commands

### Development
```bash
bin/dev                 # Start dev server with watchers
bin/rails server        # Start Rails only (no watchers)
bin/rails console       # Interactive Ruby console
```

### Database
```bash
bin/rails db:create     # Create database
bin/rails db:migrate    # Run migrations
bin/rails db:reset      # Drop, create, migrate
bin/rails db:seed       # Load seed data
```

### Generators
```bash
bin/rails generate model User name:string
bin/rails generate controller Pages home
bin/rails generate migration AddFieldToTable field:type
```

### Testing
```bash
bin/rails test          # Run tests
```

---

## Troubleshooting

### Server won't start
- Check if port 3001 is in use: `lsof -ti:3001`
- Kill process if needed: `kill -9 $(lsof -ti:3001)`

### Database errors
- Ensure PostgreSQL is running: `brew services list`
- Start PostgreSQL: `brew services start postgresql@17`

### Gem conflicts
- Update bundler: `gem install bundler`
- Reinstall gems: `bundle install`

---

## Documentation

- **Migration Plan:** [docs/RAILS_MIGRATION_PLAN.md](docs/RAILS_MIGRATION_PLAN.md)
- **Setup Complete:** [docs/SETUP_COMPLETE.md](docs/SETUP_COMPLETE.md)
- **Port Config:** [PORT_CONFIG.md](PORT_CONFIG.md)

---

## Need Help?

- Rails Guides: https://guides.rubyonrails.org/
- Hotwire: https://hotwired.dev/
- Tailwind CSS: https://tailwindcss.com/docs

---

**Happy coding! 🚀**
