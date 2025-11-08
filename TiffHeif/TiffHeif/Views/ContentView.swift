import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct ContentView: View
{
    @State private var droppedFiles: [URL] = []
    @State private var conversionStatus = ""
    @State private var outputPath = ""
    @State private var conversionProgress: Double = 0.0
    @State private var heifQuality: Double = 0.8
    @State private var isDropTargeted = false
    @State private var lossless = false
    @State private var isConverting = false
    
    private let converter = HeifConverter()
    
    var body: some View
    {
        VStack(spacing: 20)
        {
            DropZone
            {
                url in droppedFiles.append(url)
            }
            .frame(height: 200)
            progressSection.frame(height: 50)
            settingsSection
            statusSection.frame(height: 60)
        }
        .padding()
        .frame(width: 500)
        .frame(minHeight: 550)
        .backgroundStyle(.background)
    }
    
    private var progressSection: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            Text(conversionProgress > 0 ? "Converting..." : "Waiting for files...")
                .font(.caption)
                .foregroundColor(.secondary)
            ProgressView(value: conversionProgress > 0 ? conversionProgress : 0)
                .progressViewStyle(.linear)
        }
        .padding(.horizontal)
    }
    
    private var settingsSection: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            GroupBox("Output Settings")
            {
                VStack(alignment: .leading, spacing: 12)
                {
                    HStack
                    {
                        Text("Output folder:").foregroundColor(.secondary)
                        Text(outputPath)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        Button("Change")
                        {
                            outputPath = Dialogs.selectOutputDirectory()
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text("HEIF Quality: \(Int(heifQuality * 100))%").foregroundColor(.secondary)
                        Slider(value: $heifQuality, in: 0.0...1.0).disabled(lossless)
                    }
                    
                    Toggle("Lossless compression", isOn: $lossless)
                }
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
    }
    
    private var statusSection: some View
    {
        VStack(spacing: 8)
        {
            Text(droppedFiles.isEmpty ? "No files selected" : conversionStatus).foregroundColor(.secondary)
            AsyncButton(cancellation: isConverting)
            {
                await convertFiles()
            }
            label:
            {
                Text("convert")
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
            conversionStatus = "Starting conversion..."
            conversionProgress = 0.0
        }
        
        let total = droppedFiles.count
        
        do {
            for (index, sourceURL) in droppedFiles.enumerated() {
                do {
                    try await converter.convert(
                        file: sourceURL,
                        options: HeifConverter.ConversionOptions(
                            quality: heifQuality,
                            lossless: lossless,
                            outputDirectory: outputPath))
                    
                    await MainActor.run {
                        conversionProgress = Double(index + 1) / Double(total)
                        conversionStatus = "Converting file \(index + 1) of \(total)"
                    }
                } catch {
                    await MainActor.run {
                        conversionStatus = "Error converting \(sourceURL.lastPathComponent): \(error.localizedDescription)"
                    }
                    // Continue with next file instead of stopping completely
                    continue
                }
            }
            
            await MainActor.run {
                if conversionProgress >= 1.0 {
                    conversionStatus = "Conversion completed successfully!"
                    droppedFiles.removeAll()
                }
                isConverting = false
            }
        } catch {
            await MainActor.run {
                conversionStatus = "Conversion failed: \(error.localizedDescription)"
                isConverting = false
            }
        }
    }
}

#Preview
{
   ContentView()
}
