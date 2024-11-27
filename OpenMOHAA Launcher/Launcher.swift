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

class Launcher: NSViewController {
    
    @IBOutlet weak var Warning: NSTextField!
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        self.syncShellExec(path: self.scriptPath, args: ["init"])
        
        if let refreshRate = getRefreshRate() {
            UserDefaults.standard.set(refreshRate, forKey: "RefreshRate")
        } else {
            print("Konnte die Bildwiederholrate nicht ermitteln.")
        }
        
        let gametype = UserDefaults.standard.string(forKey: "GameType")
        if gametype == nil{
            UserDefaults.standard.set("0", forKey: "GameType")
        }
        
        let bloodmod = UserDefaults.standard.string(forKey: "BloodMod")
        if bloodmod == nil{
            UserDefaults.standard.set("0", forKey: "BloodMod")
        }
        
        let gameconsole = UserDefaults.standard.string(forKey: "Console")
        if gameconsole == nil{
            UserDefaults.standard.set("0", forKey: "Console")
        }
        
        let anisotropic = UserDefaults.standard.string(forKey: "Anisotropic")
        if anisotropic == nil{
            UserDefaults.standard.set("0", forKey: "Anisotropic")
        }
        
        let multisample = UserDefaults.standard.string(forKey: "Multisample")
        if multisample == nil{
            UserDefaults.standard.set("0", forKey: "Multisample")
        }
        
        let showfps = UserDefaults.standard.string(forKey: "ShowFPS")
        if showfps == nil{
            UserDefaults.standard.set("60", forKey: "ShowFPS")
        }
        
        let maxfps = UserDefaults.standard.string(forKey: "MaxFPS")
        if maxfps == nil{
            UserDefaults.standard.set("144", forKey: "MaxFPS")
        }
        
        let vsync = UserDefaults.standard.string(forKey: "VSync")
        if vsync == nil{
            UserDefaults.standard.set("1", forKey: "VSync")
        }
        
        let cheats = UserDefaults.standard.string(forKey: "Cheats")
        if cheats == nil{
            UserDefaults.standard.set("0", forKey: "Cheats")
        }
        
        self.syncShellExec(path: self.scriptPath, args: ["validate"])
        
        checkValidation()
    }
    
    func getRefreshRate() -> Int? {
        guard let mainScreen = NSScreen.main else {
            print("Error: Could not access the main screen.")
            return nil
        }
        
        // Display ID des Hauptbildschirms ermitteln
        guard let screenNumber = mainScreen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            print("Error: Could not retrieve screen number.")
            return nil
        }
        
        // Mit Core Video die Bildwiederholrate abrufen
        var displayLink: CVDisplayLink?
        let createStatus = CVDisplayLinkCreateWithCGDisplay(screenNumber, &displayLink)
        
        guard createStatus == kCVReturnSuccess, let validDisplayLink = displayLink else {
            print("Error: Could not create display link.")
            return nil
        }
        
        // Bildwiederholrate berechnen
        let time = CVDisplayLinkGetNominalOutputVideoRefreshPeriod(validDisplayLink)
        let refreshRate = Double(time.timeScale) / Double(time.timeValue)
        
        // Aufrunden und Rückgabe als Integer
        return Int(ceil(refreshRate))
    }
    
    @IBAction func quit_app(_ sender: Any) {
        NSApp.terminate(self)
    }
    
    @IBAction func openProject(_ sender: Any) {
        if let url = URL(string: "https://www.openmohaa.org/") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func openLauncher(_ sender: Any) {
        if let url = URL(string: "https://www.sl-soft.de/openmohaa-launcher") {
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
    
    func Start() {
        checkValidation()
        
        if let refreshRate = getRefreshRate() {
            UserDefaults.standard.set(refreshRate, forKey: "RefreshRate")
        } else {
            print("Konnte die Bildwiederholrate nicht ermitteln.")
        }
        
        self.syncShellExec(path: self.scriptPath, args: ["validate"])
        
        let gamevalid = UserDefaults.standard.string(forKey: "GameValid")
        if gamevalid == "1" {
            DispatchQueue.main.async {
                self.Warning.isHidden = true
                self.syncShellExec(path: self.scriptPath, args: ["start"])
            }
        } else {
            self.Warning.isHidden = false
        }
    }
    
    func checkValidation() {
        let gamevalid = UserDefaults.standard.string(forKey: "GameValid")
        if gamevalid == "1" {
            self.Warning.isHidden = true
        } else {
            self.Warning.isHidden = false
            return
        }
    }
    
    @IBAction func allied_assault(_ sender: Any) {
        UserDefaults.standard.set("0", forKey: "GameType")
        Start()
    }
    
    @IBAction func spearhead(_ sender: Any) {
        UserDefaults.standard.set("1", forKey: "GameType")
        Start()
    }
    
    @IBAction func breakthrough(_ sender: Any) {
        UserDefaults.standard.set("2", forKey: "GameType")
        Start()
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
    
