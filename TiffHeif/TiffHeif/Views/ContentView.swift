import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct ContentView: View
{
    @State private var droppedFiles: [URL] = []
    @State private var outputPath = ""
    @State private var conversionProgress: Double = 0.0
    @State private var quality: Double = 0.8
    @State private var isDropTargeted = false
    @State private var isLossless = true
    @State private var isConverting = false
    
    private let converter = HeifConverter()
    
    var body: some View
    {
        VStack(spacing: 20)
        {
            progressSection
            DropZone
            {
                url in droppedFiles
                    .append(url)
            }
            .frame(height: 200)
            .padding(.horizontal)
            targetFolderSetion
            settingsSection
            actionSection
                .frame(height: 60)
        }
        .padding()
        .frame(width: 500)
        .frame(minHeight: 470)
        .backgroundStyle(.background)
    }
    
    private var progressSection: some View
    {
        VStack()
        {
            ProgressView(value: conversionProgress > 0 ? conversionProgress : 0)
                .progressViewStyle(.linear)
                .opacity(conversionProgress > 0 ? 1 : 0)
        }
        .padding(.horizontal)
    }
    
    private var targetFolderSetion: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            HStack
            {
                Text("Output folder:")
                    .foregroundColor(.secondary)
                Text(outputPath)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
                Button("...")
                {
                    outputPath = System.selectOutputDirectory()
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal)
    }
    
    private var settingsSection: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            Toggle("Lossless compression (10b)", isOn: $isLossless)
            VStack(alignment: .leading, spacing: 8)
            {
                Text("Quality: \(Int(quality * 100))%")
                    .foregroundColor(.secondary)
                    .opacity(isLossless ? 0 : 1)
                Slider(value: $quality, in: 0.0...1.0)
                    .disabled(isLossless)
                    .opacity(isLossless ? 0 : 1)
            }
        }
        .padding(.horizontal)
    }
    
    private var actionSection: some View
    {
        VStack(spacing: 8)
        {
            AsyncButton(cancellation: isConverting)
            {
                await convertFiles()
            }
            label:
            {
                Text("Convert")
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .disabled(droppedFiles.isEmpty || isConverting || outputPath.isEmpty)
        }
    }
    
    private func convertFiles() async
    {
        await MainActor.run {
            isConverting = true
            conversionProgress = 0.0
        }
        
        let total = droppedFiles.count
        
        for (index, sourceURL) in droppedFiles.enumerated() {
            do {
                try await converter.convert(
                    file: sourceURL,
                    options: HeifConverter.ConversionOptions(
                        quality: quality,
                        lossless: isLossless,
                        outputDirectory: outputPath))
                
                await MainActor.run
                {
                    conversionProgress = Double(index + 1) / Double(total)
                }
            } catch {
                
                continue
            }
        }
        
        await MainActor.run {
            if conversionProgress >= 1.0 {
                
                droppedFiles.removeAll()
            }
            isConverting = false
        }
        
    }
}

#Preview
{
   ContentView()
}
