import Cocoa

class OverlayWindow: NSWindow {
    
    init(contentRect: NSRect) {
        super.init(contentRect: contentRect,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: false)
        
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        
        // Use the absolute maximum window level to sit above everything, including Mission Control
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        
        // CRITICAL: This allows the mouse clicks to pass through the grain to the apps below!
        self.ignoresMouseEvents = true
        
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        self.hasShadow = false
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
}
