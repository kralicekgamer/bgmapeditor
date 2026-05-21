#!/usr/bin/perl -w
################################################################################
# Copyright (c) 2006-2012, Nicolas Mazziotta
# $Id: $
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
################################################################################

use strict;
use warnings;

# Global application variables
my ($app_name, $exec_path, $file_suffix, $main_window);

################################################################################
# Module Import Section
################################################################################

use File::Basename;

# Determine installation path and handle symlinks
BEGIN {
  my $filename = $0;
  eval { $filename = readlink $0 if -l $0 };
  ($app_name, $exec_path, $file_suffix) = fileparse($filename, qw/pl/);
  # Convert backslashes to forward slashes on Windows
  $exec_path =~ s/\\/\//g if $^O =~ /^MSWin/;
}

# Add library paths for custom modules
use lib "$exec_path/lib";
use lib "$exec_path";

# Core Perl modules
use Fcntl ':flock';
use File::Path;
use File::Spec;

# CPAN modules for image handling and archives
use Archive::Zip;
use POSIX;
use GD;
use Encode;
use HTML::Entities;

# Tk GUI Framework and plugins
use Tk;
use Tk::PNG;
use Tk::ItemStyle;
use Tk::Balloon;
use Tk::Button;
use Tk::Dialog;
use Tk::Adjuster;
use Tk::TextUndo;
use Tk::NoteBook;
use Tk::Bitmap;

use MIME::Base64;
use Switch;

# Enable UTF-8 encoding fallback in Tk
$Tk::encodeFallback = 1;

# Custom application modules for tile management and editing
use TilePack;
use TileRegistry;
use ConfigReader;
use ThemeManager;
use ImageData;
use Tk::Map;
use Tk::Mapeditor;
use Tk::Tabber;
use Tk::TileChoser;
use Tk::TileChoser::AvButton;
use Tk::TileChoser::PackEntry;

################################################################################
# Global Configuration and Initialization
################################################################################

# Define application directory structure
my %app_dirs = (
  root   => $exec_path,
  images => "$exec_path/img",
  tiles  => "$exec_path/img/tiles",
  ui     => "$exec_path/img/ui",
  tmp    => "$exec_path/tmp",
  lang   => "$exec_path/lang",
);

my $config_file = "$exec_path/bgmapeditor.cfg";

# Initialize temporary directory (cleanup and recreate)
eval {
  File::Path::rmtree($app_dirs{tmp});
  File::Path::mkpath($app_dirs{tmp});
} or warn "Warning: Could not initialize temp directory: $@\n";

# Load application configuration
my %cfg = ConfigReader::readcfg($config_file);

# Ensure valid language selection (fallback to French)
unless (-f "$app_dirs{lang}/$cfg{lang}") {
  $cfg{lang} = "fr";
}

# Ensure valid theme selection (fallback to light)
$cfg{theme} ||= 'light';
unless (grep { $_ eq $cfg{theme} } ThemeManager::get_available_themes()) {
  $cfg{theme} = 'light';
}

# Load localized strings from language file
my %lang = _load_language_pack("$app_dirs{lang}/$cfg{lang}");

# Initialize default area setting
$cfg{area} = "" unless $cfg{area};

################################################################################
# GUI Initialization - Main Window and Theme Setup
################################################################################

# Create main application window with improved styling
$main_window = MainWindow->new(
  -title => $lang{title},
);

# Load and apply theme
my $theme = ThemeManager::apply_theme_to_window($cfg{theme}, $main_window);

# Modern font configuration
$main_window->fontCreate("app_normal",   -size => 10, -family => "Helvetica");
$main_window->fontCreate("app_bold",     -size => 10, -family => "Helvetica", -weight => "bold");
$main_window->fontCreate("app_small",    -size => 9,  -family => "Helvetica");

# Apply consistent styling across all widgets
$main_window->optionAdd("*font",         "app_normal");
$main_window->optionAdd("*borderWidth",  1);
$main_window->optionAdd("*background",   $theme->{bg_main});
$main_window->optionAdd("*foreground",   $theme->{fg_primary});

# Create tabbed interface with optimized layout
my $tab_manager = $main_window->Tabber(
  -border => 1,
  -font => "app_normal"
)->pack(qw/-expand 1 -fill both/);

# Status bar for user feedback and progress messages
my $status_text = "Ready";
my $status_bar = $main_window->Label(
  -textvariable => \$status_text,
  -relief => 'sunken',
  -anchor => 'w',
  -font => "app_small",
  -background => $theme->{status_bg},
  -foreground => $theme->{status_fg}
)->pack(qw/-side left -fill x -expand 1/);

################################################################################
# UI Resource Loading - Icons and Images
################################################################################

# Load UI images from directory into memory
my %ui_images = _load_ui_images($app_dirs{ui}, $main_window);
#==================================================================================#
# Menu Bar Construction - Modern hierarchical menu structure
################################################################################

my $menu_bar = $main_window->Menu(-type => 'menubar', -relief => 'flat');
$main_window->configure(-menu => $menu_bar);

# ===== FILE MENU =====
$menu_bar->Cascade(-label => $lang{m_file}, -menuitems => [
  [Button => $lang{m_new},
    -command => sub { _command_new_tab() },
    -image => $ui_images{"filenew.png"},
    -accelerator => 'Ctrl+N',
    -compound => "left",
  ],
  [Button => $lang{m_open},
    -command => sub { _command_open_map() },
    -image => $ui_images{"fileopen.png"},
    -accelerator => 'Ctrl+O',
    -compound => "left",
  ],
  [Separator => ''],
  [Button => $lang{m_save},
    -command => sub { _command_save_map() },
    -image => $ui_images{"filesave.png"},
    -accelerator => 'Ctrl+S',
    -compound => "left",
  ],
  [Button => $lang{m_save_all},
    -command => sub { _command_save_all() },
    -image => $ui_images{"save_all.png"},
    -accelerator => 'Ctrl+Shift+S',
    -compound => "left",
  ],
  [Button => $lang{m_saveas},
    -command => sub { _command_saveas_map() },
    -image => $ui_images{"filesaveas.png"},
    -accelerator => 'Ctrl+Alt+S',
    -compound => "left",
  ],
  [Button => $lang{m_convertPNG},
    -command => sub { _command_convert_map() },
    -image => $ui_images{"thumbnail.png"},
    -accelerator => 'Ctrl+P',
    -compound => "left",
  ],
  [Separator => ''],
  [Button => $lang{m_close_tab},
    -command => sub { _command_close_tab() },
    -image => $ui_images{"tab_remove.png"},
    -accelerator => 'Ctrl+W',
    -compound => "left",
  ],
  [Button => $lang{m_quit},
    -command => sub { $main_window->destroy },
    -image => $ui_images{"exit.png"},
    -accelerator => 'Alt+F4',
    -compound => "left",
  ],
]);

# ===== EDIT MENU =====
$menu_bar->Cascade(-label => $lang{m_edit}, -menuitems => [
  [Button => $lang{m_undo},
    -command => sub { $tab_manager->raised_widget->get_map->undo_undo },
    -image => $ui_images{"undo.png"},
    -accelerator => 'Ctrl+Z',
    -compound => "left",
  ],
  [Button => $lang{m_redo},
    -command => sub { $tab_manager->raised_widget->get_map->undo_redo },
    -image => $ui_images{"redo.png"},
    -accelerator => 'Ctrl+Y',
    -compound => "left",
  ],
  [Separator => ''],
  [Button => $lang{m_insert},
    -command => sub { _command_add_tile() },
    -image => $ui_images{"editpaste.png"},
    -accelerator => 'N',
    -compound => "left",
  ],
  [Button => $lang{m_drag},
    -command => sub { _command_drag_map() },
    -image => $ui_images{"view_fullscreen.png"},
    -accelerator => 'H',
    -compound => "left",
  ],
  [Button => $lang{m_move},
    -command => sub { _command_move_tile() },
    -image => $ui_images{"move.png"},
    -accelerator => 'Space',
    -compound => "left",
  ],
  [Button => $lang{m_rotate},
    -command => sub { _command_rotate_tile() },
    -image => $ui_images{"rotate_cw.png"},
    -accelerator => 'R',
    -compound => "left",
  ],
  [Button => $lang{m_delete},
    -command => sub { _command_delete_tile() },
    -image => $ui_images{"no.png"},
    -accelerator => 'D',
    -compound => "left",
  ],
  [Button => $lang{m_text},
    -command => sub { _command_text() },
    -image => $ui_images{"fonts.png"},
    -accelerator => 'T',
    -compound => "left",
  ],
]);

# ===== TILE PACKS MENU =====
$menu_bar->Cascade(-label => $lang{m_packs}, -menuitems => [
  [Button => $lang{m_add},
    -command => sub { _command_add_package() },
    -image => $ui_images{"edit_add.png"},
    -accelerator => 'Ctrl+A',
    -compound => "left",
  ],
  [Button => $lang{m_delete},
    -command => sub { _command_delete_package() },
    -image => $ui_images{"edit_remove.png"},
    -accelerator => 'Ctrl+D',
    -compound => "left",
  ],
]);

# ===== VIEW MENU =====
$menu_bar->Cascade(-label => $lang{m_view}, -menuitems => [
  [Cascade => $lang{m_theme}, -menuitems => [
    [Radiobutton => $lang{m_theme_light},
      -variable => \$cfg{theme},
      -value => 'light',
      -command => sub { _command_switch_theme('light', $theme, $main_window, $status_bar) }
    ],
    [Radiobutton => $lang{m_theme_dark},
      -variable => \$cfg{theme},
      -value => 'dark',
      -command => sub { _command_switch_theme('dark', $theme, $main_window, $status_bar) }
    ],
  ]],
]);


################################################################################
# Keyboard Shortcuts - Bind hotkeys to application commands
################################################################################

# File operations hotkeys
$main_window->bind("<Control-n>" => sub { _command_new_tab() });
$main_window->bind("<Control-o>" => sub { _command_open_map() });
$main_window->bind("<Control-s>" => sub { _command_save_map() });
$main_window->bind("<Control-S>" => sub { _command_saveas_map() });
$main_window->bind("<Control-w>" => sub { _command_close_tab() });

# Tile pack operations
$main_window->bind("<Control-p>" => sub { _command_convert_map() });
$main_window->bind("<Control-a>" => sub { _command_add_package() });
$main_window->bind("<Control-d>" => sub { _command_delete_package() });

# Undo/Redo operations
$main_window->bind("<Control-z>" => sub { $tab_manager->raised_widget->get_map->undo_undo });
$main_window->bind("<Control-y>" => sub { $tab_manager->raised_widget->get_map->undo_redo });

# Tile editing tools (fast access)
$main_window->bind("<d>" => sub { _command_delete_tile() });
$main_window->bind("<space>" => sub { _command_move_tile() });
$main_window->bind("<r>" => sub { _command_rotate_tile() });
$main_window->bind("<n>" => sub { _command_add_tile() });
$main_window->bind("<h>" => sub { _command_drag_map() });
$main_window->bind("<t>" => sub { _command_text() });

################################################################################
# Application Startup
################################################################################

# Create initial workspace or open files from command line arguments
if (@ARGV) {
  foreach (@ARGV) {
    _command_open_map($_);
  }
} else {
  _command_new_tab();
}

# Start the main event loop
MainLoop();

################################################################################
# COMMAND HANDLERS - File Operations
################################################################################

##
# _command_new_tab: Create a new editor tab with default settings
# Args: $label (optional) - Tab label name, defaults to "Unnamed"
##
sub _command_new_tab {
  my ($label) = @_;
  $label ||= $lang{l_unnamed};

  # Create new tab with Mapeditor widget
  my $new_tab = $tab_manager->tab_add(
    -label => $label,
    -raisecmd => sub {},
    -widget => 'Mapeditor',
    -options => { -border => 0 }
  );

  my $editor = $tab_manager->tab_widget($new_tab);

  # Configure editor with application resources
  $editor->configure(-ui => \%ui_images);
  my $tile_registry = TileRegistry->new(listeners => [$editor->get_tile_chooser]);
  $editor->configure(-tileregistry => $tile_registry);
  $editor->configure(-lang => \%lang);
  $editor->configure(-tilepath => $app_dirs{tiles});

  # Initialize editor components
  $editor->init_canvas_buttons;
  $editor->init_tile_chooser;
  $editor->init_map;

  $tab_manager->raise($new_tab);
}

##
# _command_close_tab: Close the currently active editor tab
##
sub _command_close_tab {
  my $current = $tab_manager->raised;
  $tab_manager->delete($current) if $current;
}

##
# _command_open_map: Open an existing map file or prompt for selection
# Args: $file (optional) - File path, if not provided shows file dialog
##
sub _command_open_map {
  my ($file) = @_;

  # Show file dialog if no file specified
  unless ($file) {
    $file = _file_dialog(
      "open",
      -filetypes => [
        [$lang{b_map}, [qw/.map/]],
        [$lang{b_all}, '*']
      ],
      -defaultextension => ".map"
    );
  }

  return 0 unless $file;

  # Check if file is already open in another tab
  foreach my $page ($tab_manager->pages) {
    my $tab_file = $tab_manager->{_tabs}{$page}{widget}{_file};
    if ($tab_file && $tab_file eq $file) {
      $tab_manager->raise($page);
      _command_close_tab();
    }
  }

  # Create new tab if none exist
  if (scalar $tab_manager->pages == 0) {
    _command_new_tab();
  }

  my $editor = $tab_manager->raised_widget;
  $editor->{_file} = $file;
  $tab_manager->label($tab_manager->raised, _basename_noext($file));

  # Load file and provide user feedback
  _msg($lang{i_loading} . " $file... ");
  $editor->load_file($file);
  _msg($lang{i_done} . " [" . localtime() . "]", 1);
  $editor->eventGenerate("<ButtonRelease-1>");
}

##
# _command_save_map: Save the current map to its file path
##
sub _command_save_map {
  my $editor = $tab_manager->raised_widget;
  return 0 unless $editor->{_file};

  _file_write_as_string($editor->{_file});
  $tab_manager->label($tab_manager->raised, _basename_noext($editor->{_file}));
}

##
# _command_saveas_map: Save the current map with a new filename
##
sub _command_saveas_map {
  _file_write_as_string();
}

##
# _command_save_all: Save all open map tabs in sequence
##
sub _command_save_all {
  my $current = $tab_manager->raised;

  foreach my $page ($tab_manager->pages) {
    $tab_manager->raise($page);
    _command_saveas_map();
  }

  $tab_manager->raise($current);
}

##
# _command_convert_map: Export current map as PNG image
##
sub _command_convert_map {
  my $editor = $tab_manager->raised_widget;

  my $file = _file_dialog(
    "save",
    -filetypes => [
      [$lang{b_png}, [qw/.png/]],
      [$lang{b_all}, '*']
    ],
    -defaultextension => ".png"
  );

  return 0 unless $file;

  _msg($lang{i_saving} . " $file... ");
  $editor->file_write_as_img($file);
  _msg($lang{i_done} . " [" . localtime() . "]", 1);
}


################################################################################
# COMMAND HANDLERS - Tile Pack Management
################################################################################

##
# _command_add_package: Add a new tile pack from a ZIP archive
##
sub _command_add_package {
  my $file = _file_dialog(
    "open",
    -filetypes => [
      [$lang{b_zip}, [qw/.zip/]],
      [$lang{b_all}, '*']
    ],
    -defaultextension => ".zip"
  );

  return 0 unless $file;

  # Unpack and load tile pack
  my $pack = TilePack::collection_build($app_dirs{tiles}, $file);

  # Update all open editors with new tiles
  foreach my $widget ($tab_manager->tab_widgets) {
    my $tile_chooser = $widget->get_tile_chooser();
    my $updated_images = $widget->cget("-images");
    $updated_images = {%{$updated_images}, $tile_chooser->load_tilepack($pack)};
    $widget->configure(-images => $updated_images);
  }

  _msg("Tile pack loaded successfully", 1);
}

##
# _command_delete_package: Remove a tile pack from all editors
##
sub _command_delete_package {
  my $current_editor = $tab_manager->raised_widget;
  my $tile_chooser = $current_editor->get_tile_chooser();

  # Collect available tile packs
  my %available_packs = ();
  foreach my $pack_id ($tile_chooser->info("children", "")) {
    my $pack_data = $tile_chooser->info("data", $pack_id);
    $available_packs{$pack_data->{name}} = $pack_id;
  }

  return 0 unless keys %available_packs;

  # Prompt user to select pack for deletion
  my $selected_pack = _prompt(
    -text => $lang{i_delete_package},
    -buttons => [sort keys %available_packs, $lang{m_cancel}]
  );

  return 0 if $selected_pack eq $lang{m_cancel};

  # Remove pack from all editors
  foreach my $widget ($tab_manager->tab_widgets) {
    my $editor_tree = $widget->get_tile_chooser();
    $editor_tree->remove_tilepack($selected_pack);
  }

  # Clean up pack files
  File::Path::rmtree("$app_dirs{tiles}/$selected_pack");
  _msg("Tile pack '$selected_pack' removed", 1);
}

################################################################################
# COMMAND HANDLERS - Tile Editing Operations
################################################################################

##
# _command_add_tile: Insert a tile at the current position
##
sub _command_add_tile {
  my $editor = $tab_manager->raised_widget;
  my $last_tile = $editor->get_map->tile_last;
  return 0 unless $last_tile;

  $editor->action_toggle('add', @{$last_tile});
}

##
# _command_text: Toggle text editing mode
##
sub _command_text {
  my $editor = $tab_manager->raised_widget;
  $editor->action_toggle('text');
}

##
# _command_delete_tile: Toggle tile deletion mode
##
sub _command_delete_tile {
  my $editor = $tab_manager->raised_widget;
  $editor->action_toggle('delete');
}

##
# _command_rotate_tile: Toggle tile rotation mode
##
sub _command_rotate_tile {
  my $editor = $tab_manager->raised_widget;
  $editor->action_toggle('rotate');
}

##
# _command_move_tile: Toggle tile movement mode
##
sub _command_move_tile {
  my $editor = $tab_manager->raised_widget;
  $editor->action_toggle('select');
}

##
# _command_drag_map: Toggle map panning/dragging mode
##
sub _command_drag_map {
  my $editor = $tab_manager->raised_widget;
  $editor->action_toggle('scan');
}

##
# _command_prompt: Show utility dialog for help/about information
##
sub _command_prompt {
  _prompt(@_);
}


################################################################################
# UTILITY FUNCTIONS - File Operations and Dialogs
################################################################################

##
# _file_dialog: Show native file open/save dialogs
# Args: $mode - "open" or "save"
#       @options - Tk dialog options
##
sub _file_dialog {
  my ($mode, @options) = @_;

  my $file;
  if ($mode eq "open") {
    $file = $main_window->getOpenFile(@options);
  } elsif ($mode eq "save") {
    $file = $main_window->getSaveFile(@options);
  }

  return $file || "";
}

##
# _file_write_as_string: Save map file with optional filename dialog
# Args: $file (optional) - File path, if not provided shows save dialog
##
sub _file_write_as_string {
  my ($file) = @_;

  unless ($file) {
    $file = _file_dialog(
      "save",
      -filetypes => [
        [$lang{b_map}, [".map"]],
        [$lang{b_all}, ["*"]]
      ],
      -defaultextension => ".map"
    );
  }

  return 0 unless $file;

  _msg($lang{i_saving} . " $file... ");

  my $editor = $tab_manager->raised_widget;
  $editor->{_file} = $file;
  $tab_manager->label($tab_manager->raised, _basename_noext($file));

  # Write map data to file
  $editor->file_write($file, join("\n", $editor->get_map->to_string));

  _msg($lang{i_done} . " [" . localtime() . "]", 1);
}

##
# _basename_noext: Extract filename without extension
# Args: $path - File path
# Returns: Filename without extension
##
sub _basename_noext {
  my ($path) = @_;

  return "" unless $path && -f $path;

  my ($name) = fileparse($path, qw/.map/);
  return $name;
}

################################################################################
# UI UTILITY FUNCTIONS - Dialogs and Messages
################################################################################

##
# _prompt: Show dialog box with text and buttons
# Args: %args - Tk Dialog options (-text, -buttons, etc.)
##
sub _prompt {
  my (%args) = @_;

  %args = (-text => $lang{w_not_implemented}) unless %args;

  my $dialog = $main_window->Dialog(
    -font => "app_normal",
    %args
  );

  return $dialog->Show("-global");
}

##
# _msg: Display status message in status bar with auto-clear
# Args: $text - Message text to display
#       $concat - If true, append to existing message (default: replace)
##
sub _msg {
  my ($text, $concat) = @_;

  if ($concat) {
    $status_text .= $text;
  } else {
    print STDERR "\n";
    $status_text = $text;
  }

  print STDERR $text;

  # Cancel previous auto-clear timer and set new one
  $main_window->{_status_timer}->cancel() if $main_window->{_status_timer};
  $main_window->{_status_timer} = $main_window->after(
    3000 => sub { $status_text = "Ready"; }
  );
}

################################################################################
# HELPER FUNCTIONS - Resource Loading
################################################################################

##
# _load_language_pack: Parse and load language file
# Args: $lang_file - Path to language file
# Returns: Hash of language strings
##
sub _load_language_pack {
  my ($lang_file) = @_;

  my %language_strings = ();

  open(my $fh, '<', $lang_file) or die "Cannot open language file: $!\n";

  while (my $line = <$fh>) {
    # Parse: KEY=VALUE or KEY='VALUE'
    if ($line =~ /^(.*?)=(["']?)(.*?)(\2)$/) {
      $language_strings{$1} = decode_entities($3);
    }
  }

  close($fh);

  return %language_strings;
}

##
# _load_ui_images: Load UI images from directory into Tk Photo objects
# Args: $ui_dir - Directory containing UI images
#       $window - Tk window for creating Photo objects
# Returns: Hash of image name => Tk Photo object
##
sub _load_ui_images {
  my ($ui_dir, $window) = @_;

  my %images = ();

  opendir(my $img_dir, $ui_dir) or die "Cannot open UI images directory: $!\n";
  my @image_files = readdir($img_dir);
  closedir($img_dir);

  foreach my $img_file (@image_files) {
    # Skip hidden files and directories
    next if $img_file =~ /^\./ || -d "$ui_dir/$img_file";

    # Only load recognized image formats
    next unless $img_file =~ /\.(png|gif|jpg|jpeg|ppm|xpm|xbm)$/i;

    # Load image directly from file
    my $full_path = "$ui_dir/$img_file";
    eval {
      my $tk_photo = $window->Photo(-file => $full_path);
      $images{$img_file} = $tk_photo;
    };
    if ($@) {
      warn "Warning: Could not load image file $img_file: $@\n";
    }
  }

  return %images;
}

################################################################################
# Theme Switching Handler
################################################################################

##
# _command_switch_theme: Switch application theme and save to config
# Args: $theme_name - 'light' or 'dark'
#       $theme_ref - Reference to theme hash
#       $main_window - Main Tk window
#       $status_bar - Status bar widget
##
sub _command_switch_theme {
  my ($theme_name, $theme_ref, $main_window, $status_bar) = @_;
  
  # Update config
  $cfg{theme} = $theme_name;
  
  # Get new theme colors
  my $new_theme = ThemeManager::get_theme($theme_name);
  
  # Apply new theme to main window
  $main_window->configure(-background => $new_theme->{bg_main});
  $main_window->optionAdd("*background", $new_theme->{bg_main});
  $main_window->optionAdd("*foreground", $new_theme->{fg_primary});
  
  # Update status bar colors
  $status_bar->configure(
    -background => $new_theme->{status_bg},
    -foreground => $new_theme->{status_fg}
  );
  
  # Save updated config to file
  _save_config_file($config_file, %cfg);
}

##
# _save_config_file: Save configuration to file
# Args: $config_path - Path to config file
#       %config - Configuration hash
##
sub _save_config_file {
  my ($config_path, %config) = @_;
  
  eval {
    open(my $cfg_fh, '>', $config_path) or die "Cannot write config: $!";
    
    # Write each config item
    foreach my $key (sort keys %config) {
      my $value = $config{$key};
      if ($value =~ /\s/ || $value =~ /['"\\#]/) {
        $value = qq("$value");
      }
      print $cfg_fh "$key=$value\n";
    }
    
    close($cfg_fh);
  } or warn "Warning: Could not save config file: $@\n";
}

################################################################################
1;

# vim: set tabstop=2 shiftwidth=2 expandtab fileencoding=utf-8 :
################################################################################

