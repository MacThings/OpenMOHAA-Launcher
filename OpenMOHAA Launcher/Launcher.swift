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
    
    @IBOutlet weak var resolutionPopUpButton: NSPopUpButton!
    
    @IBOutlet weak var game_files_found: NSTextField!
    @IBOutlet weak var open_setup: NSButton!
    
    @IBOutlet weak var play_label: NSTextField!
    @IBOutlet weak var play_image: NSImageView!
    @IBOutlet weak var play_image_r: NSImageView!
    
    @IBOutlet weak var play_button: NSButton!
    
    @IBOutlet weak var background: NSImageView!
    
    @IBOutlet weak var allied_assault: NSBox!
    @IBOutlet weak var allied_assault_label: NSTextField!
    
    @IBOutlet weak var spearhead: NSBox!
    @IBOutlet weak var spearhead_label: NSTextField!
    
    @IBOutlet weak var breakthrough: NSBox!
    @IBOutlet weak var breakthrough_label: NSTextField!
    
    @IBOutlet weak var check_for_updates: NSButton!
    @IBOutlet weak var open_changelog: NSButton!
    @IBOutlet weak var open_launcher: NSButton!
    @IBOutlet weak var open_project: NSButton!
    
    @IBOutlet weak var launcher_build: NSButton!
    
    @IBOutlet weak var serverport: NSTextField!
    @IBOutlet weak var gamespyport: NSTextField!
    
    
    let scriptPath = Bundle.main.path(forResource: "/script/script", ofType: "command")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
        
        if let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            launcher_build.title = "Launcher Build: \(appBuild)"
        } else {
            launcher_build.stringValue = "Version not found"
        }
        
        self.syncShellExec(path: self.scriptPath, args: ["validate_gamefiles"])
        
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
    
    override func viewDidAppear() {
        super.viewDidLoad()
        checkValidation()
        let gametype = UserDefaults.standard.string(forKey: "GameType")
        if gametype == "0"{
            play_allied_assault()
        }else if gametype == "1"{
            play_spearhead()
        }else if gametype == "2"{
            play_breakthrough()
        }
        
        let updates = NSLocalizedString("Check for updates", comment: "")
        let updatesString = NSAttributedString(
            string: updates,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        check_for_updates.attributedTitle = updatesString
        
        let launcher = NSLocalizedString("Launcher", comment: "")
        let launcherString = NSAttributedString(
            string: launcher,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        open_launcher.attributedTitle = launcherString
        
        let changelog = NSLocalizedString("Changelog", comment: "")
        let changelogString = NSAttributedString(
            string: changelog,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        open_changelog.attributedTitle = changelogString
        
        let project = NSLocalizedString("OpenMoHAA Project", comment: "")
        let projectString = NSAttributedString(
            string: project,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        open_project.attributedTitle = projectString
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
  
    @IBAction func openChangeLog(_ sender: Any) {
        if let url = URL(string: "https://www.sl-soft.de/extern/software/openmohaa/openmohaa.html") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func openDiscord(_ sender: Any) {
        if let url = URL(string: "https://discord.gg/NYtH58R") {
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
    
    @IBAction func start_game(_ sender: Any) {
        playSound(file: "sounds/start")
        play_image.isEnabled = false
        play_image_r.isEnabled = false
        play_label.textColor = NSColor.lightGray
        play_button.isEnabled = false
        Start()
        play_image.isEnabled = true
        play_image_r.isEnabled = true
        play_label.textColor = NSColor.white
        play_button.isEnabled = true
        
    }
    
    func Start() {
        // Überprüfen, ob der Task "openmohaa" läuft
        if isTaskRunning(named: "./openmohaa") {
            // Warnfenster anzeigen
            print("Always running")
            showTaskAlreadyRunningWarning()
            return // Aktion abbrechen
        }
        print("Not running")
        checkValidation()
        _ = getCurrentResolution()
        
        if let refreshRate = getRefreshRate() {
            UserDefaults.standard.set(refreshRate, forKey: "RefreshRate")
        } else {
            print("Konnte die Bildwiederholrate nicht ermitteln.")
        }
        
        self.syncShellExec(path: self.scriptPath, args: ["validate_gamefiles"])
        
        let gamevalid = UserDefaults.standard.string(forKey: "GameValid")
        if gamevalid == "1" {
            DispatchQueue.main.async {
                //self.Warning.isHidden = true
                self.syncShellExec(path: self.scriptPath, args: ["start"])
            }
        } else {
            play_image.isEnabled = false
            play_button.isEnabled = false
            return
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
    
    private func isTaskRunning(named taskName: String) -> Bool {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", "pgrep -f \(taskName)"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            return false
        }
        
        return !output.isEmpty // Gibt `true` zurück, wenn der Prozess läuft
    }
    
    private func showTaskAlreadyRunningWarning() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Warning", comment: "")
        alert.informativeText = NSLocalizedString("There is an openmohaa Task already running. Please close it first.", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal() // Blockiert, bis der Benutzer auf OK klickt
    }
    
    func checkValidation() {
        self.syncShellExec(path: self.scriptPath, args: ["validate_gamefiles"])
        let gamevalid = UserDefaults.standard.string(forKey: "GameValid")
        if gamevalid == "0" {
            game_files_found.stringValue = NSLocalizedString("Game Files Found: No", comment: "")
            open_setup.performClick(nil)
        } else {
            game_files_found.stringValue = NSLocalizedString("Game Files Found: Yes", comment: "")
        }
    }
    
    @IBAction func allied_assault(_ sender: Any) {
        playSound(file: "sounds/game_choose")
        UserDefaults.standard.set("0", forKey: "GameType")
        checkValidation()
        play_allied_assault()
    }
    
    @IBAction func spearhead(_ sender: Any) {
        playSound(file: "sounds/game_choose")
        UserDefaults.standard.set("1", forKey: "GameType")
        checkValidation()
        play_spearhead()
    }
    
    @IBAction func breakthrough(_ sender: Any) {
        playSound(file: "sounds/game_choose")
        UserDefaults.standard.set("2", forKey: "GameType")
        checkValidation()
        play_breakthrough()
    }
    
    
    @IBAction func reset_ports(_ sender: Any) {
        UserDefaults.standard.set("12300", forKey: "GamespyPort")
        UserDefaults.standard.set("12203", forKey: "ServerPort")
        
    }
    
    func play_allied_assault() {
        UserDefaults.standard.set("0", forKey: "GameType")
        allied_assault_label.textColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        allied_assault.fillColor = NSColor(red: 60, green: 60, blue: 60, alpha: 1)
        allied_assault.borderWidth = 0
        
        spearhead_label.textColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.85)
        spearhead.fillColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.21)
        spearhead.borderWidth = 1
        spearhead.borderColor = NSColor(red: 85, green: 85, blue: 85, alpha: 1) //#555555
        
        breakthrough_label.textColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.85)
        breakthrough.fillColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.21)
        breakthrough.borderWidth = 1
        breakthrough.borderColor = NSColor(red: 85, green: 85, blue: 85, alpha: 1) //#555555
        
        if let image = NSImage(named: "base") { // "Test" ist der Bildname (ohne Erweiterung).
            background.image = image
        } else {
            print("Bild konnte nicht geladen werden.")
        }
    }
    
    func play_spearhead() {
        UserDefaults.standard.set("1", forKey: "GameType")
        spearhead_label.textColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        spearhead.fillColor = NSColor(red: 60, green: 60, blue: 60, alpha: 1)
        spearhead.borderWidth = 0
        
        allied_assault_label.textColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.85)
        allied_assault.fillColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.21)
        allied_assault.borderWidth = 1
        allied_assault.borderColor = NSColor(red: 85, green: 85, blue: 85, alpha: 1) //#555555
        
        breakthrough_label.textColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.85)
        breakthrough.fillColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.21)
        breakthrough.borderWidth = 1
        breakthrough.borderColor = NSColor(red: 85, green: 85, blue: 85, alpha: 1) //#555555
        
        if let image = NSImage(named: "spearhead") { // "Test" ist der Bildname (ohne Erweiterung).
            background.image = image
        } else {
            print("Bild konnte nicht geladen werden.")
        }
    }
    
    func play_breakthrough() {
        UserDefaults.standard.set("2", forKey: "GameType")
        breakthrough_label.textColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        breakthrough.fillColor = NSColor(red: 60, green: 60, blue: 60, alpha: 1)
        breakthrough.borderWidth = 0
        
        allied_assault_label.textColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.85)
        allied_assault.fillColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.21)
        allied_assault.borderWidth = 1
        allied_assault.borderColor = NSColor(red: 85, green: 85, blue: 85, alpha: 1) //#555555
        
        spearhead_label.textColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.85)
        spearhead.fillColor = NSColor(red: 255, green: 255, blue: 255, alpha: 0.21)
        spearhead.borderWidth = 1
        spearhead.borderColor = NSColor(red: 85, green: 85, blue: 85, alpha: 1) //#555555
        
        if let image = NSImage(named: "breakthrough") { // "Test" ist der Bildname (ohne Erweiterung).
            background.image = image
        } else {
            print("Bild konnte nicht geladen werden.")
        }
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
    
    func playSound(file: String) {
        guard let url = Bundle.main.url(forResource: file, withExtension: "wav") else {
            print("Audio file not found")
            return
        }

        if let sound = NSSound(contentsOf: url, byReference: false) {
            sound.volume = 0.5 // Lautstärke zwischen 0.0 und 1.0
            sound.play()
        } else {
            print("Failed to play sound")
        }
    }
    
    
    func syncShellExec(path: String, args: [String] = []) {
        if let mainWindow = NSApplication.shared.windows.first {
            mainWindow.makeFirstResponder(nil)
        }
        let process            = Process()
        process.launchPath     = "/bin/bash"
        process.arguments      = [path] + args
        let outputPipe         = Pipe()
        process.standardOutput = outputPipe
        process.launch() // Start process
        process.waitUntilExit() // Wait for process to terminate.
    }
}
