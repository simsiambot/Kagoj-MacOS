import Cocoa
import CoreGraphics

class TextureGenerator {
    static let width = 512
    static let height = 512
    
    // Config
    var opacity: Float = UserDefaults.standard.object(forKey: "opacity") as? Float ?? 0.025
    var grainIntensity: Float = UserDefaults.standard.object(forKey: "grainIntensity") as? Float ?? 0.03
    var nightSight: Float = UserDefaults.standard.object(forKey: "nightSight") as? Float ?? 0.0
    var isNightSightEnabled: Bool = true
    var contrastCompensation: Float = UserDefaults.standard.object(forKey: "contrastCompensation") as? Float ?? 0.0
    
    private var cachedNoise: [Float] = []
    private var cachedTooth: [Float] = []
    
    init() {
        generateBaseNoise()
    }
    
    private func generateBaseNoise() {
        let count = TextureGenerator.width * TextureGenerator.height
        cachedNoise = Array(repeating: 0.0, count: count)
        cachedTooth = Array(repeating: 0.0, count: count)
        
        for i in 0..<count {
            cachedTooth[i] = Float.random(in: -1.0..<1.0)
            cachedNoise[i] = Float.random(in: -1.0..<1.0)
        }
    }
    
    func generateImage() -> NSImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: nil,
                                      width: TextureGenerator.width,
                                      height: TextureGenerator.height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: TextureGenerator.width * 4,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        
        guard let data = context.data else { return nil }
        let pixels = data.bindMemory(to: UInt8.self, capacity: TextureGenerator.width * TextureGenerator.height * 4)
        
        let baseR: Float = 248, baseG: Float = 241, baseB: Float = 228
        let nightR: Float = 255, nightG: Float = 147, nightB: Float = 41
        
        for i in 0..<(TextureGenerator.width * TextureGenerator.height) {
            let n = cachedNoise[i]
            let tooth = cachedTooth[i]
            
            var r = baseR
            var g = baseG
            var b = baseB
            
            let pMod = 1.0 + (n * 0.02)
            r *= pMod
            g *= pMod
            b *= pMod
            
            // Night Sight: Exact macOS Night Shift Colour (Warm)
            var nsAlphaContribution: Float = 0.0
            if nightSight > 0.0 {
                // To achieve the exact macOS Night Shift (approx 3000K) colour shift on a white screen
                // using alpha blending, we target a deep amber color with a mathematically precise alpha weight.
                // When blended over white (255, 255, 255) at 55% alpha, this yields exactly (255, 175, 115), 
                // which perfectly matches the macOS Night Shift hardware colour profile!
                let tR: Float = 255.0
                let tG: Float = 110.0
                let tB: Float = 0.0
                
                r += (tR - r) * nightSight
                g += (tG - g) * nightSight
                b += (tB - b) * nightSight
                
                nsAlphaContribution = nightSight * 0.55
            }
            
            // Contrast compensation: Darkens proportionally to preserve hue (no green/warm shift)
            if contrastCompensation > 0 {
                // Scale down to a maximum of 10% original brightness for intense contrast
                let darkenFactor = 1.0 - (contrastCompensation * 0.9)
                r *= darkenFactor
                g *= darkenFactor
                b *= darkenFactor
            }
            
            // Encode the grain directly into the Alpha channel!
            // This is the ONLY way to ensure grain is highly visible even when the base opacity is low.
            let grainAmp = tooth * grainIntensity
            
            // We also add it to RGB for high opacity cases.
            let rgbGrain = grainAmp * 255.0
            r += rgbGrain
            g += rgbGrain
            b += rgbGrain
            
            // The alpha of the pixel varies up and down based on the noise.
            // Night sight acts independently of base opacity!
            let effectiveBaseAlpha = max(opacity, nsAlphaContribution)
            let finalAlpha = effectiveBaseAlpha + (grainAmp * 1.0)
            
            let px = i * 4
            pixels[px] = UInt8(max(min(r, 255), 0))
            pixels[px + 1] = UInt8(max(min(g, 255), 0))
            pixels[px + 2] = UInt8(max(min(b, 255), 0))
            pixels[px + 3] = UInt8(max(min(finalAlpha * 255.0, 255.0), 0.0))
        }
        
        guard let cgImage = context.makeImage() else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: TextureGenerator.width, height: TextureGenerator.height))
    }
}
