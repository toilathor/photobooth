// Cuts the main subject out of a photo using Apple's on-device Vision model.
// Usage: swift scripts/cutout_subject.swift input.png output.png
// (input must be a format ImageIO reads, e.g. PNG/JPEG; output is a transparent PNG)
import CoreImage
import Foundation
import Vision

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write(Data("usage: cutout_subject input output\n".utf8))
    exit(2)
}

let input = URL(fileURLWithPath: args[1])
let output = URL(fileURLWithPath: args[2])

let handler = VNImageRequestHandler(url: input)
let request = VNGenerateForegroundInstanceMaskRequest()
try handler.perform([request])

guard let result = request.results?.first else {
    FileHandle.standardError.write(Data("no foreground subject found\n".utf8))
    exit(1)
}

let buffer = try result.generateMaskedImage(
    ofInstances: result.allInstances,
    from: handler,
    croppedToInstancesExtent: false
)
let image = CIImage(cvPixelBuffer: buffer)
try CIContext().writePNGRepresentation(
    of: image,
    to: output,
    format: .RGBA8,
    colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
)
print("wrote \(output.path)")
