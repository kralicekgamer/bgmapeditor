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

#### Build
If you are trying to build your own exe. You need exactly strawberry perl **5.30.3** portable version.

If you want newer version, good luck.

Then extract in somewhere and run `portableshell.bat`.

Next you need perl modules:
```bash
cpanm File::Basename 
cpanm Archive::Zip
cpanm GD
cpanm HTML::Entities
cpanm Tk # Very problematic module - for this you need exactly perl 5.30.3
cpanm Switch # Problematic but there is some common fixes and works too on 5.30.3
cpanm PAR::Packer --notest -v # For build. Problematic on modul test. So skip testing with -notest. 
```

Then just build with:
```bash
cd "C:\...\bgmapeditor"
pp -M deprecate --gui -o bgmapeditor.exe bgmapeditor.pl
```

### Linux
Clone the repository:
```bash
git clone https://github.com/kralicekgamer/bgmapeditor
cd bgmapeditor
```

#### Package Installation
**Debian / Ubuntu (apt):**
```bash
sudo apt update
sudo apt install perl perl-tk gd libarchive-zip-perl libhtml-parser-perl build-essential
```

**Arch Linux / Manjaro (pacman):**
```bash
sudo pacman -Syu
sudo pacman -S perl perl-tk gd perl-archive-zip perl-html-parser perl-switch base-devel
```

#### Perl Modules
```bash
# Install cpanm (Perl package manager)
sudo cpan App::cpanminus

# Install required Perl modules
cpanm File::Basename
cpanm Archive::Zip
cpanm GD
cpanm HTML::Entities
cpanm Tk
cpanm Switch
```

#### Run the application:
```bash
perl bgmapeditor.pl
```

There are no binary becouse i built it on arch and doesnt work on debian. (problem with new and old packages)

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
- **White/Black Theme** - it works +- :(

---

**Huge thanks to nmzi**