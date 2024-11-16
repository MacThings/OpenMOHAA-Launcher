//
//  ViewController.swift
//  OpenMOHAA GUI
//
//  Created by Prof. Dr. Luigi on 13.11.24.
//

import Cocoa
import Foundation
import AppKit

class ViewController: NSViewController {
    
    @IBOutlet var StartButton: NSButton!
    @IBOutlet weak var Warning: NSTextField!
    
    @IBOutlet weak var resolutionPopUpButton: NSPopUpButton!
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        self.syncShellExec(path: self.scriptPath, args: ["init"])
        
        let gametype = UserDefaults.standard.string(forKey: "GameType")
        if gametype == nil{
            UserDefaults.standard.set("0", forKey: "GameType")
        }
        
        self.syncShellExec(path: self.scriptPath, args: ["validate"])
        
        checkValidation()
        
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
        
        // Do any additional setup after loading the view

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func populateResolutionMenu() {
            resolutionPopUpButton.removeAllItems()
            
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
    
    @IBAction func openProject(_ sender: Any) {
            if let url = URL(string: "https://www.openmohaa.org/") {
                NSWorkspace.shared.open(url)
            }
        }
    
    @IBAction func openLauncher(_ sender: Any) {
            if let url = URL(string: "https://github.com/MacThings/OpenMOHAA-Launcher/") {
                NSWorkspace.shared.open(url)
            }
        }
    
    
    @IBAction func OpenPath(_ sender: Any) {
        let userPath = NSHomeDirectory() + "/Library/Application Support/openmohaa"
        let url = URL(fileURLWithPath: userPath)

        if FileManager.default.fileExists(atPath: userPath) {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } else {
            print("Dateipfad existiert nicht: \(userPath)")
        }
    }

    
    @IBAction func ValidateGame(_ sender: Any) {
        //DispatchQueue.main.async {
            self.syncShellExec(path: self.scriptPath, args: ["validate"])
        //}
        
        checkValidation()
    }
    
    
    @IBAction func StartGame(_ sender: Any) {
        
        checkValidation()
        
        self.syncShellExec(path: self.scriptPath, args: ["validate"])
        
        let gamevalid = UserDefaults.standard.string(forKey: "GameValid")
        if gamevalid == "1" {
            DispatchQueue.main.async {
                self.syncShellExec(path: self.scriptPath, args: ["start"])
            }
        } else {
            self.Warning.isHidden = false
            self.StartButton.isEnabled = false
        }
    }
    
    func checkValidation() {
        let gamevalid = UserDefaults.standard.string(forKey: "GameValid")
        if gamevalid == "1" {
            self.StartButton.isEnabled = true
            self.Warning.isHidden = true
        } else {
            self.StartButton.isEnabled = false
            self.Warning.isHidden = false
            return
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

