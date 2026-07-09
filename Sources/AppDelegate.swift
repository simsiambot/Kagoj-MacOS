import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    var statusItem: NSStatusItem!
    var overlayWindows: [OverlayWindow] = []
    let textureGenerator = TextureGenerator()
    var settingsWindow: SettingsWindow?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenuBar()
        setupOverlays()
        updateOverlays()
        showSettingsWindow()
        
        // Listen for screen changes (e.g. plugging in a second monitor)
        NotificationCenter.default.addObserver(self, selector: #selector(screenConfigurationChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func setupMenuBar() {
        // Create the system tray icon in the Mac Menu Bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "✨ Kagoj"
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Kagoj", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettingsWindow), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Kagoj", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func screenConfigurationChanged() {
        setupOverlays()
        updateOverlays()
    }
    
    @objc func showSettingsWindow() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        let width: CGFloat = 510
        let height: CGFloat = 425
        
        if let screen = NSScreen.main {
            let x = (screen.frame.width - width) / 2
            let y = (screen.frame.height - height) / 2
            let rect = NSRect(x: x, y: y, width: width, height: height)
            
            let window = SettingsWindow(contentRect: rect, delegate: self)
            window.delegate = self
            window.level = .screenSaver
            
            self.settingsWindow = window
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindow {
            settingsWindow = nil
        }
    }
    
    func setupOverlays() {
        // Remove old windows
        for window in overlayWindows {
            window.close()
        }
        overlayWindows.removeAll()
        
        // Create one overlay per physical screen
        for screen in NSScreen.screens {
            let window = OverlayWindow(contentRect: screen.frame)
            let view = NSView(frame: screen.frame)
            window.contentView = view
            overlayWindows.append(window)
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    func updateOverlays() {
        // Generate the texture once
        guard let textureImage = textureGenerator.generateImage() else { return }
        
        // NSColor(patternImage:) automatically tiles the 512x512 image across the entire screen!
        let backgroundColor = NSColor(patternImage: textureImage)
        
        // Apply it to all screens
        for window in overlayWindows {
            window.backgroundColor = backgroundColor
        }
    }
}
