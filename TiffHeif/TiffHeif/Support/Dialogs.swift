import AppKit

public class Dialogs
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
}
