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
        self.fillColor = NSColor(red: 76, green: 76, blue: 76, alpha: 1)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.fillColor = NSColor.clear // Farbe zurücksetzen, wenn die Maus weg ist
    }
}