//
//  Server.swift
//  OpenMOHAA Launcher
//
//  Created by Sascha Lamprecht on 25.11.24.
//  Copyright © 2024 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class HoverableBoxPlay: NSBox {
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
        self.fillColor = NSColor(red: 176, green: 176, blue: 176, alpha: 1)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.fillColor = NSColor(red: 210, green: 210, blue: 210, alpha: 0.3)
    }
}
