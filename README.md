# ✨ Kagoj

Kagoj is an elegant, hardware-accelerated macOS menubar utility that dynamically generates procedural paper-like textures and applies them as a permanent screen overlay. It is designed to reduce eye strain and make your digital workspace feel like a physical, tactile piece of paper.

Built fully natively in Swift using CoreGraphics, Kagoj consumes virtually zero resources while giving you complete control over texture intensity, opacity, contrast compensation, and warmth.

## Features
- **Procedural Paper Grain:** Generates high-quality, non-repeating noise using a custom cellular noise algorithm rather than static images.
- **True Night Sight:** A unique color algorithm that aggressively strips out harsh blue light and injects deep, warm amber/red tones—perfect for late-night coding or reading.
- **Contrast Compensation:** Dynamically darkens the bright "paper" base colors to protect your eyes while maintaining text readability.
- **Hardware-Accelerated:** Renders efficiently and natively without relying on heavy frameworks like Electron or web-views.
- **Seamless Multi-Monitor Support:** Automatically detects changes in your monitor setup and stretches the texture seamlessly across all displays.
- **Dock-Persistent & Space-Aware:** Kagoj sits quietly in your menubar and dock. Clicking the dock icon will instantly summon the settings window to your current Desktop Space.

## Installation
You can download the pre-compiled version directly from our **[Releases Tab](https://github.com/simsiambot/Kagoj-MacOS/releases)**.

1. Download the `Kagoj_vX.X.zip` file.
2. Unzip it and drag `Kagoj.app` into your Applications folder.
3. Open `Kagoj.app` and enjoy!

## Building from Source
If you prefer to compile Kagoj yourself, it is extremely easy! You do not even need Xcode installed—just the basic macOS Command Line Tools.

1. Clone this repository:
```bash
git clone https://github.com/simsiambot/Kagoj-MacOS.git
cd Kagoj-MacOS
```
2. Run the build script:
```bash
bash build.sh
```
3. A newly compiled `Kagoj.app` will appear in the directory. You can run it immediately!

## License
Kagoj is open-sourced under the MIT License. See the [LICENSE](LICENSE) file for more information.

---
*Crafted by studio choccymilk*
