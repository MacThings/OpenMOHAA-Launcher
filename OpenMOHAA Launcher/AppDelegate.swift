//
//  AppDelegate.swift
//  OpenMOHAA Launcher
//
//  Created by Sascha Lamprecht on 14.11.24.
//

import Cocoa
import Foundation
import CoreVideo

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
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
        
        let screenmode = UserDefaults.standard.string(forKey: "ScreenMode")
        if screenmode == nil{
            UserDefaults.standard.set("Fullscreen", forKey: "ScreenMode")
        }

        let grabmouse = UserDefaults.standard.string(forKey: "GrabMouse")
        if grabmouse == nil{
            UserDefaults.standard.set("1", forKey: "GrabMouse")
        }
        
        let crosshair = UserDefaults.standard.string(forKey: "Crosshair")
        if crosshair == nil{
            UserDefaults.standard.set("1", forKey: "Crosshair")
        }
        
        if let refreshRate = getRefreshRate() {
            UserDefaults.standard.set(refreshRate, forKey: "RefreshRate")
        } else {
            print("Konnte die Bildwiederholrate nicht ermitteln.")
        }
        
        _ = getCurrentResolution()
        
        self.syncShellExec(path: self.scriptPath, args: ["validate_gamefiles"])
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
    
    func getCurrentResolution() -> String? {
        guard let mainScreen = NSScreen.main else {
            return nil
        }
        
        let width = Int(mainScreen.frame.width)
        let height = Int(mainScreen.frame.height)
        let currentResolution = "\(width) x \(height)"
        UserDefaults.standard.set(currentResolution, forKey: "CurrentResolution")
        
        return currentResolution

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
