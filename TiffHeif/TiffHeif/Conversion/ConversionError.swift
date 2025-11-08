enum ConversionError: Error
{
    case invalidSourceFile
    case conversionFailed
    case destinationCreationFailed
    case outputDirectoryNotFound
    case sourceFileNotFound
    case sourceFileNotAccessible
    case addImageFailed
    
    var description: String
    {
        switch self
        {
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
