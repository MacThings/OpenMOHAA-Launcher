//
//  Server.swift
//  OpenMOHAA Launcher
//
//  Created by Sascha Lamprecht on 25.11.24.
//  Copyright © 2024 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class HoverableBoxSetup: NSBox {
    private var trackingArea: NSTrackingArea?
    private var hoverTimer: Timer?
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        // Entferne die alte Tracking-Area, falls vorhanden
        if let trackingArea = trackingArea {
            self.removeTrackingArea(trackingArea)
        }
        
        // Erstelle eine neue Tracking-Area
        let newTrackingArea = NSTrackingArea(
            rect: self.bounds,
            options: [.mouseEnteredAndExited, .activeInActiveApp],
            owner: self,
            userInfo: nil
        )
        self.addTrackingArea(newTrackingArea)
        self.trackingArea = newTrackingArea
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        self.fillColor = NSColor(red: 76/255, green: 76/255, blue: 76/255, alpha: 1)
        
        // Starte einen Timer, der die Farbe nach 2 Sekunden zurücksetzt
        hoverTimer?.invalidate() // Bereits vorhandenen Timer beenden
        hoverTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.fillColor = NSColor.clear
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        hoverTimer?.invalidate() // Timer stoppen, wenn die Maus den Bereich verlässt
        self.fillColor = NSColor.clear // Farbe zurücksetzen
    }
}
