import AppKit

public class System
{
    public static func selectOutputDirectory() -> String
    {
        let panel = NSOpenPanel()
        
        panel.title = "Choose Output Directory"
        panel.showsHiddenFiles = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        
        return panel.runModal() == .OK
            ? panel.url?.path ?? NSHomeDirectory()
            : ""
    }
    
    public static func showAlert(error: Error)
    {
        let alert = NSAlert()
        alert.messageText = error.localizedDescription
        alert.alertStyle = .critical
        alert.runModal()
    }
}
