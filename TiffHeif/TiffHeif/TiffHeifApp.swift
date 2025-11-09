import SwiftUI

@main
struct TiffHeifApp: App
{
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .frame(width: 500, height: 500)
        }
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate
{
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        true
    }
}
