# Wonderland NixOS Branding Assets

This directory contains branding assets for the Wonderland NixOS installation ISO.

## Required Images

Create the following images for your ISO:

### 1. BIOS Boot Splash (`wonderland-splash-bios.png`)
- **Resolution**: 640x480 pixels
- **Format**: PNG
- **Purpose**: Shown during BIOS boot
- **Tips**: Keep it simple, high contrast works best

### 2. EFI Boot Splash (`wonderland-splash-efi.png`)
- **Resolution**: 1920x1080 pixels (or higher)
- **Format**: PNG
- **Purpose**: Shown during UEFI boot
- **Tips**: Can be more detailed than BIOS splash

### 3. Boot Logo (`wonderland-logo.png`)
- **Resolution**: Any (512x512 recommended)
- **Format**: PNG with transparency
- **Purpose**: Used in Plymouth boot animation
- **Tips**: Keep it simple for animation

## Creating Your Branding

### Quick Start with Placeholders

For testing, you can use placeholder images:

```bash
# Create simple placeholder (requires ImageMagick)
convert -size 640x480 xc:purple -pointsize 72 -fill white \
  -gravity center -annotate +0+0 "Wonderland\nNixOS" \
  wonderland-splash-bios.png

convert -size 1920x1080 xc:purple -pointsize 120 -fill white \
  -gravity center -annotate +0+0 "Wonderland\nNixOS" \
  wonderland-splash-efi.png
```

### Design Tips

**Color Scheme**:
- Use your theme colors (purple #b82aff seems to be your accent)
- Keep backgrounds dark for better readability
- Ensure good contrast for text

**Layout**:
- Center your logo/text
- Leave margins for different screen ratios
- Test on both 4:3 and 16:9 displays

**Tools**:
- GIMP (free, powerful)
- Inkscape (vector graphics)
- Figma (online design tool)
- ImageMagick (command-line tool)

## Integration

Once you have your images, uncomment these lines in `iso-config.nix`:

```nix
splashImage = ./branding/wonderland-splash-bios.png;
efiSplashImage = ./branding/wonderland-splash-efi.png;
```

Then rebuild your ISO:
```bash
nix build .#nixosConfigurations.wonderland-iso.config.system.build.isoImage
```

## Example Themes

Look at these for inspiration:
- **NixOS**: Simple snowflake logo on dark background
- **Ubuntu**: Orange/purple gradient with white logo
- **Fedora**: Blue background with white logo
- **Arch**: Minimalist blue logo on black

## File Checklist

- [ ] `wonderland-splash-bios.png` (640x480)
- [ ] `wonderland-splash-efi.png` (1920x1080+)
- [ ] `wonderland-logo.png` (512x512)
- [ ] Images are PNG format
- [ ] File sizes are reasonable (<5MB each)
- [ ] Tested in ISO build
