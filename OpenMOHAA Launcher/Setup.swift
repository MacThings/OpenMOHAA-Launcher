//
//  ViewController.swift
//  OpenMOHAA GUI
//
//  Created by Sascha Lamprecht on 13.11.24.
//

import Cocoa
import Foundation
import AppKit
import CoreVideo

class Setup: NSViewController {
    
    @IBOutlet weak var box_installed: NSBox!
    @IBOutlet weak var box_gog: NSBox!
    
    
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
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
                    self.checksum_gog_installer()
                }
            } else {
                print("Keine Datei ausgewählt.")
            }
        }
    }
    
    @IBAction func gog_already_installed(_ sender: Any) {
        // Erstelle einen NSOpenPanel
        let openPanel = NSOpenPanel()
        
        // Konfiguriere das OpenPanel
        openPanel.canChooseFiles = false // Keine Dateien auswählen
        openPanel.canChooseDirectories = true // Nur Ordner auswählen
        openPanel.allowsMultipleSelection = false // Nur einen Ordner auswählen
        openPanel.prompt = "Ordner auswählen"
        
        // Zeige den Dialog und handle die Auswahl
        openPanel.begin { result in
            if result == .OK {
                // Hole den Pfad der ausgewählten Datei
                if let selectedPath = openPanel.url?.path {
                    // Speichere den Pfad in UserDefaults
                    UserDefaults.standard.set(selectedPath, forKey: "GOGAlreadyInstalled")
                    self.gog_already_installed()
                }
            } else {
                print("Kein Ordner ausgewählt.")
            }
        }
    }
    
    func checksum_gog_installer()
    {
        self.syncShellExec(path: self.scriptPath, args: ["checksum_gog_installer"])
        
        let gog_checksum = UserDefaults.standard.string(forKey: "GOGChecksumOk")
        
        if gog_checksum == "1"{
            //self.import_gog()
        } else {
            let alert = NSAlert()
                alert.messageText = NSLocalizedString("Wrong GOG Installer!", comment: "")
                alert.informativeText = NSLocalizedString("The GOG installer is not valid. Please verify the integrity of the installer and/or makle sure you have the correct one.", comment: "")
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.runModal()
        }
    }
    
    func import_gog() {
        DispatchQueue.main.async {
            //self.gog_button.title = NSLocalizedString("Please wait ...", comment: "")
            self.syncShellExec(path: self.scriptPath, args: ["gog_install"])
            //self.gog_button.title = NSLocalizedString("Done", comment: "")
            //self.gog_button.isEnabled = false
        }
    }

    func gog_already_installed() {
        DispatchQueue.main.async {
            self.syncShellExec(path: self.scriptPath, args: ["gog_already_installed"])
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("Warning", comment: "")
            alert.informativeText = NSLocalizedString("There is an openmohaa Task already running. Please close it first.", comment: "")
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal() // Blockiert, bis der Benutzer auf OK klickt
            
            UserDefaults.standard.removeObject(forKey: "GOGAlreadyInstalled")
            self.checkValidation()
        }
    }
    
    func checkValidation() {
        self.syncShellExec(path: self.scriptPath, args: ["validate_gamefiles"])
        let gamevalid = UserDefaults.standard.string(forKey: "GameValid")
        if gamevalid == "0" {
            print("Not valid")
        } else {
            print("Valid")
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
    
