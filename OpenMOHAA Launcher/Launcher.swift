//
//  ViewController.swift
//  OpenMOHAA GUI
//
//  Created by Prof. Dr. Luigi on 13.11.24.
//

import Cocoa
import Foundation
import AppKit

class Launcher: NSViewController {
    
    @IBOutlet weak var Warning: NSTextField!
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        self.syncShellExec(path: self.scriptPath, args: ["init"])
        
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
        
        let fps = UserDefaults.standard.string(forKey: "FPS")
        if fps == nil{
            UserDefaults.standard.set("60", forKey: "FPS")
        }
        
        let maxfps = UserDefaults.standard.string(forKey: "MaxFPS")
        if maxfps == nil{
            UserDefaults.standard.set("144", forKey: "MaxFPS")
        }
        
        self.syncShellExec(path: self.scriptPath, args: ["validate"])
        
        checkValidation()
        
        
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
    