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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            print("bla")
            if let selectedResolution = sender.selectedItem?.title {
                UserDefaults.standard.set(selectedResolution, forKey: "Resolution")
            }
        }
}

