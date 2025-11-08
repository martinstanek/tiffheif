import SwiftUI

@main
struct TiffHeifApp: App
{
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
