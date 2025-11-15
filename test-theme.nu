#!/usr/bin/env nu
# Temporary test script - adds omarchy scripts to PATH and tests theme switching

# Add scripts to PATH
$env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.HOME)/.script" | prepend $"($env.HOME)/.local/share/omarchy/bin")

print "PATH updated. Testing theme switching..."
print $"Current theme: (basename (readlink ~/.config/omarchy/current/theme))"
print ""
print "Run: theme"
print "to test theme switching"
