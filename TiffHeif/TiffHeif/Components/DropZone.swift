import SwiftUI
import UniformTypeIdentifiers

struct DropZone: View
{
    @State private var droppedFiles: [URL] = []
    @State private var isDropTargeted = false
    
    var onFileDropped: (URL) -> Void
    
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
                        if let fileType = try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier, (UTType(fileType)?.conforms(to: .tiff) ?? false)
                        {
                            droppedFiles.append(url)
                            onFileDropped(url)
                        }
                    }
                }
            }
            return true
        }
    }
}
