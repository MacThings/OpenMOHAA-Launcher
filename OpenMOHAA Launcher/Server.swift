//
//  Server.swift
//  OpenMOHAA Launcher
//
//  Created by Sascha Lamprecht on 25.11.24.
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
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = [path] + args
        let outputPipe = Pipe()
        let fileHandler = outputPipe.fileHandleForReading
        process.standardOutput = outputPipe
        
        let group = DispatchGroup()
        group.enter()
        fileHandler.readabilityHandler = { pipe in
            let data = pipe.availableData
            if data.isEmpty { // EOF
                fileHandler.readabilityHandler = nil
                group.leave()
                return
            }
            if let line = String(data: data, encoding: .utf8) {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Zeilen ignorieren, die mit "=>" oder "Backtrace" beginnen
                if trimmedLine.hasPrefix("=>") || trimmedLine.hasSuffix("Backtrace:") {
                    return
                }
                
                DispatchQueue.main.sync {
                    let attributedString = NSAttributedString(
                        string: line,
                        attributes: [
                            .foregroundColor: NSColor.green, // Text in Grün
                            .font: NSFont(name: "Courier", size: 12) ?? NSFont.systemFont(ofSize: 12) // Schriftart Courier
                        ]
                    )
                    self.output_window.textStorage?.append(attributedString)
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
