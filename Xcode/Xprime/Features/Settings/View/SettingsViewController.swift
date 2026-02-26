// The MIT License (MIT)
//
// Copyright (c) 2025-2026 Insoft.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa

final class SettingsViewController: NSViewController, NSTextFieldDelegate {
    @IBOutlet weak var substitution: NSSwitch!
    @IBOutlet weak var theme: NSPopUpButton!
    @IBOutlet weak var location: NSTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear() {
        guard let window = view.window else { return }
        
        // Make window background transparent
        window.titleVisibility = .hidden
        window.center()
        window.titlebarAppearsTransparent = true
        window.styleMask = [.nonactivatingPanel, .titled]
        window.styleMask.insert(.fullSizeContentView)
    }
    
    private func setup() {
        configureThemeSelection()
        configureSubtitutionActions()
        
        location.stringValue = UserDefaults.standard.string(forKey: "location") ?? FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Xprime")
            .path
        
        location.delegate = self
    }
    
    func controlTextDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else { return }

        switch textField.tag {
        case 1:
            UserDefaults.standard.set(textField.stringValue, forKey: "location")
            break;
        default:
            break
        }
    }
    
    // MARK: - Actions
    @objc private func preferSubtitutionSwitchToggled(_ sender: NSSwitch) {
        UserDefaults.standard.set(sender.state == .on, forKey: "SubtitutionEnabled")
    }
    
    @objc private func handleThemeSelection(_ sender: NSMenuItem) {
        UserDefaults.standard.set(sender.title, forKey: "preferredTheme")
    }
    
    
    @IBAction func close(_ sender: Any) {
        self.view.window?.close()
    }
    
    @IBAction func defaultSettings(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "SubtitutionEnabled")
        UserDefaults.standard.set("Default (Dark)", forKey: "preferredTheme")
        UserDefaults.standard.set(
            FileManager
                .default
                .homeDirectoryForCurrentUser
                .appendingPathComponent("Xprime")
                .path,
            forKey: "location"
        )
            
        location.stringValue = FileManager
            .default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Xprime")
            .path
        substitution.state = .off
        theme.selectItem(withTitle: "Default (Dark)")
        
    }
    
    // MARK: - Private Helpers
    private func configureThemeSelection() {
        guard let resourceURLs = Bundle.main.urls(
            forResourcesWithExtension: "xpcolortheme",
            subdirectory: "Themes"
        ) else {
#if Debug
            print("⚠️ No .xpcolortheme files found.")
#endif
            return
        }
        
        let sortedURLs = resourceURLs
            .filter { !$0.lastPathComponent.hasPrefix(".") }
            .sorted {
                $0.deletingPathExtension().lastPathComponent
                    .localizedCaseInsensitiveCompare(
                        $1.deletingPathExtension().lastPathComponent
                    ) == .orderedAscending
            }
        
        let themeName = UserDefaults.standard.string(forKey: "preferredTheme") ?? "Default (Dark)"
        
        for fileURL in sortedURLs {
            let name = fileURL.deletingPathExtension().lastPathComponent
            
            let menuItem = NSMenuItem(
                title: name,
                action: #selector(handleThemeSelection(_:)),
                keyEquivalent: ""
            )
            menuItem.representedObject = fileURL
            menuItem.target = self
            menuItem.state = themeName == name ? .on : .off
            
            theme.menu!.addItem(menuItem)
        }
        
        theme.selectItem(withTitle: themeName)
    }
    
    private func configureSubtitutionActions() {
        substitution.target = self
        substitution.action = #selector(preferSubtitutionSwitchToggled(_:))
    }
}
