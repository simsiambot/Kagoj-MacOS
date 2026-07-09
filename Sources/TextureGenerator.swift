import Cocoa
import CoreGraphics

class TextureGenerator {
    static let width = 512
    static let height = 512
    
    // Config
    var opacity: Float = UserDefaults.standard.object(forKey: "opacity") as? Float ?? 0.0
    var grainIntensity: Float = UserDefaults.standard.object(forKey: "grainIntensity") as? Float ?? 0.0
    var contrastCompensation: Float = UserDefaults.standard.object(forKey: "contrastCompensation") as? Float ?? 0.0
    var isActive: Bool = UserDefaults.standard.object(forKey: "isActive") as? Bool ?? false
    
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
        
        let darkFactor: Float = 1.0 - (contrastCompensation * 0.5)
        
        let baseR: Float = 248.0 * darkFactor
        let baseG: Float = 241.0 * darkFactor
        let baseB: Float = 228.0 * darkFactor
        
        let grainR: Float = 0.0
        let grainG: Float = 0.0
        let grainB: Float = 128.0
        
        let pulpStrength: Float = 0.02
        let grainStrength: Float = 1.5 * grainIntensity
        
        for i in 0..<(TextureGenerator.width * TextureGenerator.height) {
            let n = cachedNoise[i]
            let tooth = cachedTooth[i]
            
            let pMod = 1.0 + (n * pulpStrength)
            var curR = baseR * pMod
            var curG = baseG * pMod
            var curB = baseB * pMod
            
            var grainAmp: Float = 0.0
            
            if tooth < 0.0 {
                let factor = -tooth * grainStrength
                curR += (grainR - curR) * factor
                curG += (grainG - curG) * factor
                curB += (grainB - curB) * factor
                grainAmp = factor
            } else {
                let factor = tooth * grainStrength
                curR += (255.0 - curR) * factor
                curG += (255.0 - curG) * factor
                curB += (255.0 - curB) * factor
                grainAmp = factor
            }
            
            // finalAlpha is the base opacity + extra alpha for grain
            let finalAlpha = max(min(opacity + grainAmp, 1.0), 0.0)
            
            // Premultiply RGB by alpha for CGImageAlphaInfo.premultipliedLast
            let px = i * 4
            pixels[px] = UInt8(max(min(curR * finalAlpha, 255.0), 0.0))
            pixels[px + 1] = UInt8(max(min(curG * finalAlpha, 255.0), 0.0))
            pixels[px + 2] = UInt8(max(min(curB * finalAlpha, 255.0), 0.0))
            pixels[px + 3] = UInt8(finalAlpha * 255.0)
        }
        
        guard let cgImage = context.makeImage() else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: TextureGenerator.width, height: TextureGenerator.height))
    }
}
