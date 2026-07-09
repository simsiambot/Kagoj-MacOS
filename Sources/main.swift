import Cocoa

// Initialize the shared application instance
let app = NSApplication.shared

// Create and attach the AppDelegate
let delegate = AppDelegate()
app.delegate = delegate

// Run the main event loop!
app.run()
