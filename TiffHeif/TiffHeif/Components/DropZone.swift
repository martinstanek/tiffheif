import SwiftUI
import UniformTypeIdentifiers

struct DropZone: View
{
    @State private var message = "no files dropped"
    @State private var isDropTargeted = false
    @State private var fileCount: Int = 0
    private var onFileDropped: (URL) -> Void
    
    init(onFileDropped: @escaping (URL) -> Void)
    {
        self.onFileDropped = onFileDropped
    }
    
    var body: some View
    {
        ZStack
        {
            RoundedRectangle(cornerRadius: 12)
                .fill(isDropTargeted ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                .frame(minHeight: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .foregroundColor(isDropTargeted ? .blue : .gray))
            
            VStack(spacing: 12)
            {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 40))
                Text("Drop your TIFF files here")
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted)
        { providers in
            Task
            {
                for provider in providers
                {
                    if let item = try? await provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier),
                       let data = item as? Data,
                       let path = String(data: data, encoding: .utf8),
                       let url = URL(string: path)
                    {
                        if (isTiffFile(url: url))
                        {
                            onFileDropped(url)
                            fileCount = fileCount + 1
                            message = "\(fileCount) files dropped"
                        }
                        else
                        {
                            message = "only TIFF files supported"
                        }
                    }
                }
            }
            return true
        }
    }
    
    private func isTiffFile(url: URL) -> Bool
    {
        let fileType = try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier
        
        return (UTType(fileType!)?.conforms(to: .tiff) ?? false)
    }
}
