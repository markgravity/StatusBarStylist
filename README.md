# StatusBarStylist

StatusBarStylist is a framework to supports changing the Status Bar style with natural SwiftUI syntax.

Thank [Philip Trauner](https://stackoverflow.com/a/71458976/10270556) for this source code and idea.

## Installation
Requirements iOS 14+

### Swift Package Manager 
1. In Xcode, open your project and navigate to File → Swift Packages → Add Package Dependency.
2. Paste the repository URL (https://github.com/markgravity/StatusBarStylist) and click Next.
3. For Rules, select version.
4. Click Finish.

### Swift Package
```swift
.package(url: "https://github.com/markgravity/StatusBarStylist", .upToNextMajor(from: "1.0.0"))
```

## Usage

In your ```@main``` App file, simply wrap your main view in a ```RootView```.

```swift
@main
struct ProjectApp: App {     
    var body: some Scene {
        WindowGroup {
            RootView {
                ContentView() // Change your content here 👈
            }
        }
    }
}
```

### Example
Use the ```.statusBarStyle(_ style: UIStatusBarStyle)``` method on a View.
```swift
struct ContentView: View {
    var body: some View {
        TabView {
            // Tab  1 will have a light status bar
            Color.black
                .edgesIgnoringSafeArea(.all)
                .overlay(Text("Light Status Bar").foregroundColor(.white))
                .statusBarStyle(.lightContent) // set status bar style here
                .tabItem { Text("Tab 1") }
            
            // Tab 2 will have a dark status bar
            Color.white
                .edgesIgnoringSafeArea(.all)
                .overlay(Text("Dark Status Bar"))
                .statusBarStyle(.darkContent) // set status bar style here
                .tabItem { Text("Tab 2") }
        }
    }
}
````

## Contribute
You can contribute to this project by helping me solve any [reported issues or feature requests](https://github.com/markgravity/StatusBarStylist/issues) and creating a pull request.

## License
StatusBarStylist is released under the [MIT License](LICENSE).