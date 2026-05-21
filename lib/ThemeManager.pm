# Copyright (c) 2024, Theme Manager
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

#######################################################
package ThemeManager;
#######################################################

use strict;

# Define theme color schemes
my %themes = (
  light => {
    bg_main        => '#f0f0f0',
    bg_secondary   => '#e8e8e8',
    bg_input       => '#ffffff',
    fg_primary     => '#333333',
    fg_secondary   => '#666666',
    fg_tertiary    => '#999999',
    border         => '#cccccc',
    accent         => '#0066cc',
    status_bg      => '#e0e0e0',
    status_fg      => '#666666',
    highlight      => '#e6f2ff',
    error          => '#cc0000',
    success        => '#009900',
    warning        => '#ff9900',
  },
  dark => {
    bg_main        => '#2b2b2b',
    bg_secondary   => '#3a3a3a',
    bg_input       => '#1e1e1e',
    fg_primary     => '#e0e0e0',
    fg_secondary   => '#b0b0b0',
    fg_tertiary    => '#808080',
    border         => '#555555',
    accent         => '#4da6ff',
    status_bg      => '#3a3a3a',
    status_fg      => '#b0b0b0',
    highlight      => '#1a3a4d',
    error          => '#ff6666',
    success        => '#66ff66',
    warning        => '#ffcc66',
  },
);

# Get theme colors for a specific theme
sub get_theme {
  my ($theme_name) = @_;
  $theme_name ||= 'light';
  
  # Validate theme name
  unless (exists $themes{$theme_name}) {
    warn "Warning: Unknown theme '$theme_name', using 'light' instead\n";
    $theme_name = 'light';
  }
  
  return $themes{$theme_name};
}

# Get a specific color from a theme
sub get_color {
  my ($theme_name, $color_key) = @_;
  my $theme = get_theme($theme_name);
  return $theme->{$color_key} || '#000000';
}

# Apply theme to Tk main window
sub apply_theme_to_window {
  my ($theme_name, $main_window) = @_;
  my $theme = get_theme($theme_name);
  
  $main_window->configure(-background => $theme->{bg_main});
  $main_window->optionAdd("*background",   $theme->{bg_main});
  $main_window->optionAdd("*foreground",   $theme->{fg_primary});
  $main_window->optionAdd("*borderWidth",  1);
  
  return $theme;
}

# Get list of available themes
sub get_available_themes {
  return sort keys %themes;
}

1;

# vim:ts=2 sw=2
