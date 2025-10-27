# rex-mining

A comprehensive mining system for RedM featuring dynamic rock placement, drilling mechanics, and rare gemstone discovery.

**Version:** 2.0.5  
**Game:** RedM (RDR3)

## 🔗 Links
- **Discord:** https://discord.gg/YUV7ebzkqs
- **YouTube:** https://www.youtube.com/@rexshack/videos
- **Tebex:** https://rexshackgaming.tebex.io/

---

## ✨ Features

### Core Mining System
- **Dynamic Rock Node Placement** - Players and admins can place mining nodes anywhere in the world
- **Pickaxe Mining** - Use pickaxes to mine rocks for various minerals and resources
- **Rock Drilling Workshops** - Process mined rocks at drilling stations in Valentine, Blackwater, Tumbleweed, Van Horn, and Guarma
- **Automatic Rock Respawning** - Rocks automatically regenerate every 5 minutes (configurable via cronjob)

### Resources & Items
- **Standard Minerals:** Clay, Coal, Copper, Iron, Nitrite, Sulfur, Zinc, Lead
- **Salt Mining:** Dedicated salt rock nodes with salt extraction
- **Rare Gemstones:** 5% chance to discover uncut diamonds, rubies, emeralds, opals, and sapphires

### Customization & Configuration
- **Adjustable Mining Times** - Configure pickaxe mining and drill processing durations
- **Player Limits** - Set maximum mining nodes per player (default: 10, 0 = unlimited)
- **Distance Controls** - Minimum spacing between placed rocks
- **Vegetation Clearing** - Optional vegetation removal around rocks (toggle for performance)
- **Blip Customization** - Show/hide map blips for drilling locations

### Administration & Security
- **Admin Commands** - Create rock nodes with admin-only commands
- **Admin Logging** - Track prop creation/destruction for audits
- **Distance Validation** - Maximum mining distance enforcement (3.0m default)
- **Discord Webhooks** - Optional admin log integration
- **Database Persistence** - All placed nodes saved to database

### Quality of Life
- **Multiple Drilling Locations** - 5 preset workshop locations across the map
- **Localization Support** - JSON-based language system (English included)
- **Notification System** - Integrated with rNotify
- **Version Checker** - Automatic update notifications

---

## 📋 Dependencies

Required dependencies:
- **rsg-core** - Core framework
- **ox_target** - Targeting system
- **ox_lib** - Utility library
- **oxmysql** - Database wrapper

---

## 🔧 Installation

### Step 1: Install Dependencies
Ensure all dependencies are installed and added to your `server.cfg` before rex-mining.

### Step 2: Add Resource Files
1. Copy `rex-mining` folder to your server's `resources` directory

### Step 3: Database Setup
1. Import `installation/rex-mining.sql` into your database

### Step 4: Add Items
1. Open `installation/shared_items.lua`
2. Copy all item definitions to your `rsg-core/shared/items.lua` file

### Step 5: Add Item Images
1. Copy all images from `installation/images/` folder
2. Paste into `rsg-inventory/html/images/` directory

### Step 6: Configure Server
Add the following line to your `server.cfg`:
```cfg
ensure rex-mining
```

### Step 7: Restart Server
Restart your server or use `refresh` and `ensure rex-mining`

---

## ⚙️ Configuration

Edit `shared/config.lua` to customize:

- **Mining Times:** Adjust `Config.MiningTime` (default: 10 seconds)
- **Drill Times:** Adjust `Config.DrillTime` (default: 10 seconds per rock)
- **Gemstone Chance:** Modify `Config.GemChance` (default: 5%)
- **Player Limits:** Set `Config.MaxPropsPerPlayer` (default: 10)
- **Respawn Rate:** Change `Config.MiningCronJob` (default: every 5 minutes)
- **Rock Models:** Customize prop models for rocks and drills
- **Drilling Locations:** Add/remove workshop coordinates
- **Resource Outputs:** Modify mineral drop pools

---

## 🎮 Usage

### For Players
1. **Mining Rocks:**
   - Approach a rock node
   - Use a pickaxe to mine
   - Receive random minerals with a chance for rare gems

2. **Drilling Rocks:**
   - Collect rocks/salt rocks from mining
   - Visit a drilling workshop (marked on map)
   - Process rocks into refined materials

3. **Placing Rocks:**
   - Use rock items to place personal mining nodes
   - Limited to 10 nodes per player (configurable)
   - Must maintain minimum distance from other rocks

### For Admins
- `/createrocknode` - Creates a standard rock node (saved to database)
- `/createsaltrocknode` - Creates a salt rock node (saved to database)

---

## 🗺️ Default Locations

**Drilling Workshops:**
- Valentine Rock Drilling
- Blackwater Rock Drilling
- Tumbleweed Rock Drilling
- Van Horn Rock Drilling
- Guarma Rock Drilling

**Mine Locations:**
- Created by your admin team

---

## 🐛 Troubleshooting

- **Rocks not spawning:** Check database connection and ensure SQL file was imported
- **Mining not working:** Verify pickaxe item exists in items.lua
- **Performance issues:** Disable `Config.EnableVegModifier` in config.lua
- **Drilling locations not showing:** Ensure `showblip = true` in workshop configuration

---

## 📝 License

This is a premium resource. Please support the developer through official channels.

---

## 💬 Support

For support, join the Discord server: https://discord.gg/YUV7ebzkqs
