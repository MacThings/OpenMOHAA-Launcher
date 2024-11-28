//
//  ViewController.swift
//  OpenMOHAA GUI
//
//  Created by Sascha Lamprecht on 13.11.24.
//

import Cocoa
import Foundation
import AppKit

class Settings: NSViewController {
    
    @IBOutlet weak var resolutionPopUpButton: NSPopUpButton!
    @IBOutlet weak var gog_button: NSButton!
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        populateResolutionMenu()
        
        // Prüfe, ob bereits eine gespeicherte Auflösung existiert
                if let savedResolution = UserDefaults.standard.string(forKey: "Resolution") {
                    // Wenn ja, setze diese als Vorauswahl
                    resolutionPopUpButton.selectItem(withTitle: savedResolution)
                } else if let firstResolution = resolutionPopUpButton.itemTitles.first {
                    // Wenn keine gespeicherte Auflösung existiert, setze die erste Auflösung als Standard
                    resolutionPopUpButton.selectItem(withTitle: firstResolution)
                    UserDefaults.standard.set(firstResolution, forKey: "Resolution")
                }
        }
    
    func populateResolutionMenu() {
        // Alle vorhandenen Einträge entfernen
        resolutionPopUpButton.removeAllItems()
        
        // "Desktop" immer an erster Stelle hinzufügen
        resolutionPopUpButton.addItem(withTitle: "Desktop")
        
        for screen in NSScreen.screens {
            if let screenID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
                
                // Optionen zum Einbeziehen von HiDPI-Auflösungen
                let options: CFDictionary = [kCGDisplayShowDuplicateLowResolutionModes as String: kCFBooleanTrue] as CFDictionary
                
                if let modes = CGDisplayCopyAllDisplayModes(screenID, options) as? [CGDisplayMode] {
                    for mode in modes {
                        let width = Int(mode.width)
                        let height = Int(mode.height)
                        let isHiDPI = mode.pixelWidth > mode.width
                        let resolutionString = "\(width) x \(height)" + (isHiDPI ? " *" : "")
                        
                        if resolutionPopUpButton.itemTitles.contains(resolutionString) == false {
                            resolutionPopUpButton.addItem(withTitle: resolutionString)
                        }
                    }
                }
            }
        }
    }
        
    
        @IBAction func resolutionChanged(_ sender: NSPopUpButton) {
            if let selectedResolution = sender.selectedItem?.title {
                UserDefaults.standard.set(selectedResolution, forKey: "Resolution")
            }
        }
    
    @IBAction func gog_installer(_ sender: Any) {
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
                            self.import_gog()
                        }
                    } else {
                        print("Keine Datei ausgewählt.")
                    }
                }
    }
    
    
    func import_gog() {
        DispatchQueue.main.async {
            self.gog_button.title = NSLocalizedString("Please wait ...", comment: "")
            self.syncShellExec(path: self.scriptPath, args: ["gog_install"])
            self.gog_button.title = NSLocalizedString("Done", comment: "")
            self.gog_button.isEnabled = false
        }
    }
    

    @IBAction func openGOG(_ sender: Any) {
            if let url = URL(string: "https://www.gog.com/en/game/medal_of_honor_allied_assault_war_chest") {
                NSWorkspace.shared.open(url)
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

