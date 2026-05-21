# BGMapEditor - Board Game Map Editor

**BGMapEditor**  is an opensource editor for boardgames such as Zombicide, Space Hulk and other dungeon crawlers and games with modular boards. Although more than 13 years old, bgmapeditor is still used to create novel scenarios. Feel free to download it and to modify whatever you want.

## What is it?
BGMapEditor allows you to:
- Create and edit maps for your favorite board games
- Work with tiles on modular boards
- Export maps to images
- Save projects in a proprietary format

## Installation
### Windows
Download relase on releases page or just download this whole repo. Then just run `bgmapeditor.exe`

### Linux
Clone the repository:
```bash
git clone https://github.com/kralicekgamer/bgmapeditor
cd bgmapeditor
```

Run the binary:
```bash
chmod +x bgmapeditor
./bgmapeditor
```


## Project Structure
```
bgmapeditor/
├── bgmapeditor.pl          # Main application file
├── bgmapeditor.cfg         # Configuration file
├── lib/                    # Custom Perl modules
│   ├── ConfigReader.pm     # Configuration reader
│   ├── ImageData.pm        # Image manipulation
│   ├── TilePack.pm         # Tile package management
│   ├── TileRegistry.pm     # Registry of available tiles
│   ├── ThemeManager.pm     # Theme/style management
│   └── Tk/                 # Tk GUI components
│       ├── Map.pm          # Map component
│       ├── Mapeditor.pm    # Map editor
│       ├── Tabber.pm       # Tab widget
│       ├── TileChoser.pm   # Tile selection
│       └── TileChoser/     # TileChooser sub-components
├── img/                    # Images and icons
│   ├── tiles/              # Tile images
│   └── ui/                 # UI icons
├── lang/                   # Language files (cs, de, en, fr, pt, ru)
├── fonts/                  # Font files
└── tmp/                    # Temporary files (runtime)
```

## Changes
- **Restructured project layout** - Moved all files from nested `trunk/` directory to root level for simpler access
- **Added support for additional languages** - Czech (cs), German (de), and Russian (ru) language files
- **Code optimization** - Performance improvements and refactoring of the main application code
- **Cleanup** - Removed obsolete files and streamlined the repository structure
- **Improved documentation** - Added inline comments for better code maintainability

---

**Huge thanks to nmzi**