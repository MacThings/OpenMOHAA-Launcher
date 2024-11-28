//
//  AppDelegate.swift
//  OpenMOHAA Launcher
//
//  Created by Sascha Lamprecht on 14.11.24.
//

import Cocoa
import Foundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed (_
                                                          theApplication: NSApplication) -> Bool {
        return true
    }
    @IBAction func import_gog(_ sender: Any) {
        // Erstelle einen NSOpenPanel
        
        
        let openPanel = NSOpenPanel()
        
        // Konfiguriere das OpenPanel
        openPanel.title = "Wähle eine Datei"
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["exe"] // Nur .exe-Dateien erlauben
        
        // Zeige den Dialog und handle die Auswahl
        openPanel.begin { result in
            if result == .OK {
                // Hole den Pfad der ausgewählten Datei
                if let selectedPath = openPanel.url?.path {
                    // Speichere den Pfad in UserDefaults
                    UserDefaults.standard.set(selectedPath, forKey: "GOGInstaller")
                    self.import_gog_installer()
                }
            } else {
                print("Keine Datei ausgewählt.")
            }
        }
    }
    
    
    
    func import_gog_installer() {
        DispatchQueue.main.async {
            self.syncShellExec(path: self.scriptPath, args: ["gog_install"])
        }
    }
    
    func syncShellExec(path: String, args: [String] = []) {
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        process.standardOutput = outputPipe
        process.launch() // Start process
        process.waitUntilExit() // Wait for process to terminate.
    }
    
    
}
