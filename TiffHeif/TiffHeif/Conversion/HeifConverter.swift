import Foundation
import CoreImage
import ImageIO
import UniformTypeIdentifiers
import CoreGraphics

// TODO: interface, bindeable ... progress done internally
class HeifConverter
{
    enum ConversionError: Error
    {
        case invalidSourceFile
        case conversionFailed
        case destinationCreationFailed
        case outputDirectoryNotFound
        case sourceFileNotFound
        case sourceFileNotAccessible
        case addImageFailed
        
        var description: String {
            switch self {
            case .invalidSourceFile:
                return "Source file is not a valid TIFF image"
            case .conversionFailed:
                return "Failed to convert the image"
            case .destinationCreationFailed:
                return "Failed to create output file"
            case .outputDirectoryNotFound:
                return "Output directory not found"
            case .sourceFileNotFound:
                return "Source file not found"
            case .sourceFileNotAccessible:
                return "Cannot access source file"
            case .addImageFailed:
                return "Failed to add image to destination"
            }
        }
    }
    
    struct ConversionOptions
    {
        let quality: Double
        let lossless: Bool
        let outputDirectory: String
    }
    
    func convert(file: URL, options: ConversionOptions) async throws
    {
        guard FileManager.default.fileExists(atPath: options.outputDirectory)
        else
        {
            throw ConversionError.outputDirectoryNotFound
        }
        
        let outputExtension = options.lossless ? "heif" : "heic"
        let filename = file.deletingPathExtension().lastPathComponent
        let destinationURL = URL(fileURLWithPath: options.outputDirectory)
            .appendingPathComponent(filename)
            .appendingPathExtension(outputExtension)
        
        do {
            try await convertImage(
                source: file,
                destination: destinationURL,
                conversionOptions: options
            )
        }
        catch let error as ConversionError
        {
            throw error
        }
    }
    
    private func convertImage(source: URL, destination: URL, conversionOptions: ConversionOptions) async throws
    {
        return try await Task.detached(priority: .userInitiated) {
            guard let image = CIImage(contentsOf: source) else {
                throw ConversionError.invalidSourceFile
            }
            
            guard let colorSpace = image.colorSpace else {
                throw ConversionError.conversionFailed
            }
            
            let context = CIContext(options: nil)
            let quality = conversionOptions.lossless ? 1.0 : conversionOptions.quality
            let options = [kCGImageDestinationLossyCompressionQuality: quality] as [CFString: Any]
            
            do {
                if conversionOptions.lossless {
                    try context.writeHEIF10Representation(
                        of: image,
                        to: destination,
                        colorSpace: colorSpace,
                        options: options as [CIImageRepresentationOption : Any])
                } else {
                    try context.writeHEIFRepresentation(
                        of: image,
                        to: destination,
                        format: CIFormat.ARGB8,
                        colorSpace: colorSpace,
                        options: options as [CIImageRepresentationOption : Any])
                }
            } catch {
                throw ConversionError.conversionFailed
            }
        }.value
    }
}
