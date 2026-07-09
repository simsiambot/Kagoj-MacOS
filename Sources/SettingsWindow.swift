import Cocoa
import CoreGraphics

class SettingsWindow: NSWindow {
    
    init(contentRect: NSRect, delegate: AppDelegate) {
        super.init(contentRect: contentRect,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: false)
        
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.hasShadow = true
        self.isMovableByWindowBackground = false
        
        // Create and set the custom content view
        let customContentView = XPWindowContentView(frame: contentRect, delegate: delegate)
        self.contentView = customContentView
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}

// Custom Close Button for the Windows XP Title Bar
class XPCloseButton: NSButton {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.title = ""
        self.bezelStyle = .shadowlessSquare
        self.isBordered = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.saveGState()
        
        let b = self.bounds.insetBy(dx: 1, dy: 1)
        
        // Classic XP Red-orange Close button gradient
        let startColor = NSColor(red: 0.98, green: 0.45, blue: 0.35, alpha: 1.0)
        let endColor = NSColor(red: 0.82, green: 0.15, blue: 0.05, alpha: 1.0)
        let gradient = NSGradient(starting: startColor, ending: endColor)
        
        let path = NSBezierPath(roundedRect: b, xRadius: 3, yRadius: 3)
        gradient?.draw(in: path, angle: 90)
        
        // Thin dark blue border
        NSColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 1.0).setStroke()
        path.lineWidth = 1.0
        path.stroke()
        
        // Draw the white X symbol
        NSColor.white.setStroke()
        let xPath = NSBezierPath()
        let padding: CGFloat = 5
        xPath.move(to: NSPoint(x: b.minX + padding, y: b.minY + padding))
        xPath.line(to: NSPoint(x: b.maxX - padding, y: b.maxY - padding))
        xPath.move(to: NSPoint(x: b.minX + padding, y: b.maxY - padding))
        xPath.line(to: NSPoint(x: b.maxX - padding, y: b.minY + padding))
        xPath.lineWidth = 2.0
        xPath.lineCapStyle = .round
        xPath.stroke()
        
        ctx?.restoreGState()
    }
}



// Custom Checkbox Cell
class XPCheckboxCell: NSButtonCell {
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.saveGState()
        
        // Box
        let boxSize: CGFloat = 13
        let boxRect = NSRect(x: cellFrame.minX, y: cellFrame.midY - boxSize/2, width: boxSize, height: boxSize)
        
        // Classic XP dark blue border for checkbox
        NSColor(red: 0.11, green: 0.23, blue: 0.58, alpha: 1.0).setStroke()
        let border = NSBezierPath(rect: boxRect)
        border.lineWidth = 1.0
        
        // Fill white background
        NSColor.white.set()
        border.fill()
        border.stroke()
        
        // Green checkmark if ON
        if self.state == .on {
            NSColor(red: 0.13, green: 0.69, blue: 0.30, alpha: 1.0).setStroke() // XP Bright Green
            let check = NSBezierPath()
            check.move(to: NSPoint(x: boxRect.minX + 3, y: boxRect.minY + 6))
            check.line(to: NSPoint(x: boxRect.minX + 5.5, y: boxRect.minY + 9.5))
            check.line(to: NSPoint(x: boxRect.minX + 11, y: boxRect.minY + 2))
            check.lineWidth = 2.0
            check.lineCapStyle = .square
            check.stroke()
        }
        
        // Title
        let attr = self.attributedTitle
        let titleRect = NSRect(x: boxRect.maxX + 6, y: cellFrame.minY + (cellFrame.height - attr.size().height)/2, width: cellFrame.width - boxRect.width - 8, height: attr.size().height)
        attr.draw(in: titleRect)
        
        ctx?.restoreGState()
    }
}

// Custom Slider Cell to draw Windows XP styled track and thumb
class XPSliderCell: NSSliderCell {
    
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        // Draw the recessed XP slider track
        let barRect = NSRect(x: rect.origin.x, y: rect.origin.y + (rect.height - 4) / 2, width: rect.width, height: 4)
        
        // Recessed shadow border
        NSColor(red: 0.55, green: 0.55, blue: 0.52, alpha: 1.0).setStroke()
        let border = NSBezierPath(rect: barRect)
        border.lineWidth = 1.0
        border.stroke()
        
        // Fill center track with white
        NSColor.white.set()
        let inner = NSBezierPath(rect: barRect.insetBy(dx: 0.5, dy: 0.5))
        inner.fill()
    }
    
    override func drawKnob(_ knobRect: NSRect) {
        let ctx = NSGraphicsContext.current?.cgContext
        ctx?.saveGState()
        
        // Narrow rectangular thumb box
        let kRect = knobRect.insetBy(dx: 4, dy: 1)
        
        // Classic XP Metallic slider thumb gradient
        let bgGradient = NSGradient(starting: NSColor(white: 0.98, alpha: 1.0),
                                   ending: NSColor(white: 0.78, alpha: 1.0))
        bgGradient?.draw(in: kRect, angle: 90)
        
        // Thumb border
        NSColor(white: 0.4, alpha: 1.0).setStroke()
        let border = NSBezierPath(rect: kRect)
        border.lineWidth = 1.0
        border.stroke()
        
        // Draw small indicator notch in center
        NSColor(red: 0.0, green: 0.35, blue: 0.9, alpha: 1.0).setStroke()
        let notch = NSBezierPath()
        notch.move(to: NSPoint(x: kRect.midX, y: kRect.minY + 2))
        notch.line(to: NSPoint(x: kRect.midX, y: kRect.maxY - 2))
        notch.lineWidth = 1.5
        notch.stroke()
        
        ctx?.restoreGState()
    }
}

// Custom GroupBox with double-bevel 3D border
class XPGroupBox: NSView {
    var title: String = ""
    
    init(frame frameRect: NSRect, title: String) {
        super.init(frame: frameRect)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let borderRect = bounds.insetBy(dx: 2, dy: 2)
        
        // 3D recessed border colors
        NSColor(red: 0.65, green: 0.65, blue: 0.62, alpha: 1.0).setStroke()
        let darkBorder = NSBezierPath(rect: borderRect)
        darkBorder.lineWidth = 1.0
        darkBorder.stroke()
        
        NSColor.white.setStroke()
        let lightBorder = NSBezierPath(rect: borderRect.offsetBy(dx: 1, dy: -1))
        lightBorder.lineWidth = 1.0
        lightBorder.stroke()
        
        if !title.isEmpty {
            // Draw group title over the top border
            let font = NSFont(name: "Tahoma-Bold", size: 11) ?? NSFont.boldSystemFont(ofSize: 11)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor(red: 0.05, green: 0.2, blue: 0.6, alpha: 1.0)
            ]
            
            let titleSize = title.size(withAttributes: attrs)
            // Background overlay to clear the border under the text
            let textBgRect = NSRect(x: 12, y: bounds.height - titleSize.height / 2 - 2, width: titleSize.width + 8, height: titleSize.height)
            NSColor(red: 0.925, green: 0.914, blue: 0.847, alpha: 1.0).set() // XP dialog beige
            textBgRect.fill()
            
            title.draw(at: NSPoint(x: 16, y: bounds.height - titleSize.height / 2 - 2), withAttributes: attrs)
        }
    }
}

// The window content view that draws the XP style container and coordinates controls
class XPWindowContentView: NSView {
    
    weak var delegate: AppDelegate?
    
    var titleBarHeight: CGFloat = 30
    var windowBorderWidth: CGFloat = 4
    
    var closeButton: XPCloseButton!
    var groupBox: XPGroupBox!
    
    var opacitySlider: NSSlider!
    var opacityLabelVal: NSTextField!
    
    var grainSlider: NSSlider!
    var grainLabelVal: NSTextField!
    
    var contrastSlider: NSSlider!
    var contrastLabelVal: NSTextField!
    
    var nightSightSlider: NSSlider!
    var nightSightLabelVal: NSTextField!
    
    init(frame frameRect: NSRect, delegate: AppDelegate) {
        self.delegate = delegate
        super.init(frame: frameRect)
        
        // Setup window appearance (macOS standard sizing)
        let w: CGFloat = 320
        let h: CGFloat = 250 // Increased to fit 4th slider
        self.bounds = NSRect(x: 0, y: 0, width: w, height: h)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func createLabel(_ text: String, font: NSFont, alignRight: Bool = false) -> NSTextField {
        let label = NSTextField()
        label.isEditable = false
        label.isSelectable = false
        label.isBezeled = false
        label.drawsBackground = false
        label.stringValue = text
        label.font = font
        label.textColor = NSColor.black
        if alignRight {
            label.alignment = .right
        }
        return label
    }
    
    private func setupViews() {
        // 1. Close Button
        let closeBtnRect = NSRect(x: bounds.width - 26, y: bounds.height - 25, width: 21, height: 21)
        closeButton = XPCloseButton(frame: closeBtnRect)
        closeButton.target = self
        closeButton.action = #selector(closeClicked)
        addSubview(closeButton)
        
        // 2. Group Box
        let boxRect = NSRect(x: 12, y: 52, width: bounds.width - 24, height: bounds.height - 96)
        groupBox = XPGroupBox(frame: boxRect, title: "")
        addSubview(groupBox)
        
        let tFont = NSFont(name: "Tahoma", size: 11) ?? NSFont.systemFont(ofSize: 11)
        
        // Custom cell instances to apply the XP style to sliders
        let opacityCell = XPSliderCell()
        let grainCell = XPSliderCell()
        let contrastCell = XPSliderCell()
        let nightSightCell = XPSliderCell()
        
        let yBase = boxRect.minY + 20
        let rowH: CGFloat = 30
        
        let labelW: CGFloat = 135
        let sliderX: CGFloat = 145
        let sliderW: CGFloat = 90
        
        // Row 3: Opacity
        let opLabel = createLabel("Opacity:", font: tFont)
        opLabel.frame = NSRect(x: 20, y: yBase + rowH * 3, width: labelW, height: 18)
        addSubview(opLabel)
        
        opacitySlider = NSSlider()
        opacitySlider.cell = opacityCell
        opacitySlider.minValue = 0.0
        opacitySlider.maxValue = 1.0 // UI max is 100%
        let currentOp = delegate?.textureGenerator.opacity ?? 0.0
        opacitySlider.doubleValue = Double(currentOp / 0.5) // Map engine value (0-0.5) to UI value (0-1.0)
        opacitySlider.target = self
        opacitySlider.action = #selector(sliderChanged(_:))
        opacitySlider.frame = NSRect(x: sliderX, y: yBase + rowH * 3, width: sliderW, height: 20)
        addSubview(opacitySlider)
        
        opacityLabelVal = createLabel("\(Int((currentOp / 0.5) * 100))%", font: tFont, alignRight: true)
        opacityLabelVal.frame = NSRect(x: 240, y: yBase + rowH * 3, width: 40, height: 18)
        addSubview(opacityLabelVal)
        
        // Row 2: Grain Intensity
        let grLabel = createLabel("Grain Intensity:", font: tFont)
        grLabel.frame = NSRect(x: 20, y: yBase + rowH * 2, width: labelW, height: 18)
        addSubview(grLabel)
        
        grainSlider = NSSlider()
        grainSlider.cell = grainCell
        grainSlider.minValue = 0.0
        grainSlider.maxValue = 1.0 // UI max is 100%
        let currentGr = delegate?.textureGenerator.grainIntensity ?? 0.0
        grainSlider.doubleValue = Double(currentGr / 0.12) // Map engine value (0-0.12) to UI value (0-1.0)
        grainSlider.target = self
        grainSlider.action = #selector(sliderChanged(_:))
        grainSlider.frame = NSRect(x: sliderX, y: yBase + rowH * 2, width: sliderW, height: 20)
        addSubview(grainSlider)
        
        grainLabelVal = createLabel("\(Int((currentGr / 0.12) * 100))%", font: tFont, alignRight: true)
        grainLabelVal.frame = NSRect(x: 240, y: yBase + rowH * 2, width: 40, height: 18)
        addSubview(grainLabelVal)
        
        // Row 1: Contrast Compensation
        let ctLabel = createLabel("Contrast Compensation:", font: tFont)
        ctLabel.frame = NSRect(x: 20, y: yBase + rowH * 1, width: labelW, height: 18)
        addSubview(ctLabel)
        
        contrastSlider = NSSlider()
        contrastSlider.cell = contrastCell
        contrastSlider.minValue = 0.0
        contrastSlider.maxValue = 1.0
        contrastSlider.doubleValue = Double(delegate?.textureGenerator.contrastCompensation ?? 0.0)
        contrastSlider.target = self
        contrastSlider.action = #selector(sliderChanged(_:))
        contrastSlider.frame = NSRect(x: sliderX, y: yBase + rowH * 1, width: sliderW, height: 20)
        addSubview(contrastSlider)
        
        contrastLabelVal = createLabel("\(Int((delegate?.textureGenerator.contrastCompensation ?? 0.0) * 100))%", font: tFont, alignRight: true)
        contrastLabelVal.frame = NSRect(x: 240, y: yBase + rowH * 1, width: 40, height: 18)
        addSubview(contrastLabelVal)
        
        // Row 0: Night Sight
        let nsLabel = createLabel("Night Sight:", font: tFont)
        nsLabel.frame = NSRect(x: 20, y: yBase + rowH * 0, width: labelW, height: 18)
        addSubview(nsLabel)
        
        nightSightSlider = NSSlider()
        nightSightSlider.cell = nightSightCell
        nightSightSlider.minValue = 0.0
        nightSightSlider.maxValue = 1.0
        nightSightSlider.doubleValue = Double(delegate?.textureGenerator.nightSight ?? 0.0)
        nightSightSlider.target = self
        nightSightSlider.action = #selector(sliderChanged(_:))
        nightSightSlider.frame = NSRect(x: sliderX, y: yBase + rowH * 0, width: sliderW, height: 20)
        addSubview(nightSightSlider)
        
        nightSightLabelVal = createLabel("\(Int((delegate?.textureGenerator.nightSight ?? 0.0) * 100))%", font: tFont, alignRight: true)
        nightSightLabelVal.frame = NSRect(x: 240, y: yBase + rowH * 0, width: 40, height: 18)
        addSubview(nightSightLabelVal)
        


        // Copyright Label (Moved to bottom right)
        let copyLabel = createLabel("© studio choccymilk", font: NSFont(name: "Tahoma", size: 10) ?? NSFont.systemFont(ofSize: 10), alignRight: true)
        copyLabel.frame = NSRect(x: bounds.width - 162, y: 16, width: 150, height: 16)
        copyLabel.textColor = NSColor(white: 0.3, alpha: 1.0)
        addSubview(copyLabel)
    }
    
    @objc func sliderChanged(_ sender: NSSlider) {
        guard let delegate = delegate else { return }
        
        if sender == opacitySlider {
            let val = Float(sender.doubleValue)
            delegate.textureGenerator.opacity = val * 0.5 // Map UI (0-1.0) to Engine (0-0.5)
            UserDefaults.standard.set(delegate.textureGenerator.opacity, forKey: "opacity")
            opacityLabelVal.stringValue = "\(Int(val * 100))%"
        } else if sender == grainSlider {
            let val = Float(sender.doubleValue)
            delegate.textureGenerator.grainIntensity = val * 0.12 // Map UI (0-1.0) to Engine (0-0.12)
            UserDefaults.standard.set(delegate.textureGenerator.grainIntensity, forKey: "grainIntensity")
            grainLabelVal.stringValue = "\(Int(val * 100))%"
        } else if sender == contrastSlider {
            let val = Float(sender.doubleValue)
            delegate.textureGenerator.contrastCompensation = val
            UserDefaults.standard.set(val, forKey: "contrastCompensation")
            contrastLabelVal.stringValue = "\(Int(val * 100))%"
        } else if sender == nightSightSlider {
            let val = Float(sender.doubleValue)
            delegate.textureGenerator.nightSight = val
            UserDefaults.standard.set(val, forKey: "nightSight")
            nightSightLabelVal.stringValue = "\(Int(val * 100))%"
        }
        
        // Notify delegate to regenerate overlays in real-time
        delegate.updateOverlays()
    }
    
    @objc func closeClicked() {
        self.window?.orderOut(nil)
    }
    
    override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)
        
        // Detect click on the title bar area
        let titleBarRect = NSRect(x: 0, y: bounds.height - titleBarHeight, width: bounds.width, height: titleBarHeight)
        if titleBarRect.contains(point) {
            self.window?.performDrag(with: event)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let bounds = self.bounds
        
        // 1. Draw solid Windows XP dialog background color (beige/gray)
        NSColor(red: 0.925, green: 0.914, blue: 0.847, alpha: 1.0).set()
        let bgPath = NSBezierPath(rect: bounds)
        bgPath.fill()
        
        // 2. Draw thick blue outer frame border (with rounded top corners)
        let outerRadius: CGFloat = 8.0
        let borderPath = NSBezierPath()
        borderPath.move(to: NSPoint(x: bounds.minX, y: bounds.minY))
        borderPath.line(to: NSPoint(x: bounds.maxX, y: bounds.minY))
        borderPath.line(to: NSPoint(x: bounds.maxX, y: bounds.maxY - outerRadius))
        borderPath.appendArc(withCenter: NSPoint(x: bounds.maxX - outerRadius, y: bounds.maxY - outerRadius),
                             radius: outerRadius,
                             startAngle: 0,
                             endAngle: 90)
        borderPath.line(to: NSPoint(x: bounds.minX + outerRadius, y: bounds.maxY))
        borderPath.appendArc(withCenter: NSPoint(x: bounds.minX + outerRadius, y: bounds.maxY - outerRadius),
                             radius: outerRadius,
                             startAngle: 90,
                             endAngle: 180)
        borderPath.close()
        
        NSColor(red: 0.0, green: 0.33, blue: 0.88, alpha: 1.0).set()
        borderPath.lineWidth = windowBorderWidth * 2
        borderPath.stroke()
        
        // 3. Draw blue gradient Windows XP Luna title bar background
        let titleBarRect = NSRect(x: windowBorderWidth,
                                  y: bounds.height - titleBarHeight,
                                  width: bounds.width - windowBorderWidth * 2,
                                  height: titleBarHeight - windowBorderWidth / 2)
        
        // Rounded title bar path
        let titleRadius = outerRadius - windowBorderWidth / 2
        let titleBarPath = NSBezierPath()
        titleBarPath.move(to: NSPoint(x: titleBarRect.minX, y: titleBarRect.minY))
        titleBarPath.line(to: NSPoint(x: titleBarRect.maxX, y: titleBarRect.minY))
        titleBarPath.line(to: NSPoint(x: titleBarRect.maxX, y: titleBarRect.maxY - titleRadius))
        titleBarPath.appendArc(withCenter: NSPoint(x: titleBarRect.maxX - titleRadius, y: titleBarRect.maxY - titleRadius),
                               radius: titleRadius,
                               startAngle: 0,
                               endAngle: 90)
        titleBarPath.line(to: NSPoint(x: titleBarRect.minX + titleRadius, y: titleBarRect.maxY))
        titleBarPath.appendArc(withCenter: NSPoint(x: titleBarRect.minX + titleRadius, y: titleBarRect.maxY - titleRadius),
                               radius: titleRadius,
                               startAngle: 90,
                               endAngle: 180)
        titleBarPath.close()
        
        let titleGradient = NSGradient(starting: NSColor(red: 0.0, green: 0.35, blue: 0.9, alpha: 1.0),
                                       ending: NSColor(red: 0.23, green: 0.58, blue: 1.0, alpha: 1.0))
        titleGradient?.draw(in: titleBarPath, angle: 0)
        
        // 4. Draw title bar text with drop shadow
        let font = NSFont(name: "Tahoma-Bold", size: 12) ?? NSFont.boldSystemFont(ofSize: 12)
        let textShadow = NSShadow()
        textShadow.shadowColor = NSColor(red: 0.0, green: 0.15, blue: 0.45, alpha: 0.75)
        textShadow.shadowOffset = NSSize(width: 1, height: -1)
        textShadow.shadowBlurRadius = 1
        
        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
            .shadow: textShadow
        ]
        
        let titleText = "Kagoj"
        let textSize = titleText.size(withAttributes: textAttrs)
        let textY = bounds.height - titleBarHeight + (titleBarHeight - textSize.height) / 2
        titleText.draw(at: NSPoint(x: 12, y: textY), withAttributes: textAttrs)
    }
}
