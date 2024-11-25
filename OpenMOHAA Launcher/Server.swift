//
//  Server.swift
//  OpenMOHAA Launcher
//
//  Created by Prof. Dr. Luigi on 25.11.24.
//  Copyright © 2024 Sascha Lamprecht. All rights reserved.
//

import Cocoa
import Foundation
import AppKit

class Server: NSViewController, NSWindowDelegate {
     
    @IBOutlet var output_window: NSTextView!
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidAppear() {
        super.viewDidLoad()

        // Setze den Delegaten des Fensters
        if let window = view.window {
            window.delegate = self
        } else {
            print("Fenster konnte nicht gefunden werden!")
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        self.syncShellExec(path: self.scriptPath, args: ["stop_server"])
    }
    
    @IBAction func start_server(_ sender: Any) {
        // Setzt die Schriftart auf Courier
            output_window.font = NSFont(name: "Courier", size: 12)

        DispatchQueue.global(qos: .background).async {
            self.syncShellExec(path: self.scriptPath, args: ["start_server"])
            }
        }
   
    
    @IBAction func stop_server(_ sender: Any) {
        self.syncShellExec(path: self.scriptPath, args: ["stop_server"])
    }
    
    func syncShellExec(path: String, args: [String] = []) {
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        let filelHandler       = outputPipe.fileHandleForReading
        process.standardOutput = outputPipe
        
        let group = DispatchGroup()
        group.enter()
        filelHandler.readabilityHandler = { pipe in
            let data = pipe.availableData
            if data.isEmpty { // EOF
                filelHandler.readabilityHandler = nil
                group.leave()
                return
            }
            if let line = String(data: data, encoding: String.Encoding.utf8) {
                DispatchQueue.main.sync {
                    self.output_window.string += line
                    self.output_window.scrollToEndOfDocument(nil)
                }
            } else {
                print("Error decoding data: \(data.base64EncodedString())")
            }
        }
        process.launch() // Start process
        process.waitUntilExit() // Wait for process to terminate.
    }
    
}
