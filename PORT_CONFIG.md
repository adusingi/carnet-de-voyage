# Port Configuration

## Development Ports

To avoid conflicts between your two projects:

| Project | Port | URL | Command |
|---------|------|-----|---------|
| **Next.js (Noteplan)** | 3000 | http://localhost:3000 | `npm run dev` |
| **Rails (Carnet de Voyage)** | 3001 | http://localhost:3001 | `bin/dev` |

## Running Both Projects Simultaneously

### Terminal 1 - Next.js
```bash
cd /Users/adusingi/Documents/Noteplan
npm run dev
```
Visit: http://localhost:3000

### Terminal 2 - Rails
```bash
cd /Users/adusingi/Documents/carnet-de-voyage
bin/dev
```
Visit: http://localhost:3001

---

## Configuration Files Changed

- `Procfile.dev` - Updated web command to use `-p 3001`
- `config/puma.rb` - Changed default PORT from 3000 to 3001

---

## Why This Matters

You can now:
- ✅ Reference your Next.js MVP while building Rails
- ✅ Copy UI elements and compare implementations
- ✅ Port code from one project to the other
- ✅ Run both apps side-by-side for testing

---

**No more port conflicts!** 🎉
