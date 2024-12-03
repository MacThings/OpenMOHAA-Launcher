//
//  Server.swift
//  OpenMOHAA Launcher
//
//  Created by Sascha Lamprecht on 25.11.24.
//  Copyright © 2024 Sascha Lamprecht. All rights reserved.
//

import Cocoa

class HoverableLink: NSButton {
    private var trackingArea: NSTrackingArea?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Setzt den anfänglichen Titel ohne Unterstreichung und in Standardfarbe
        updateTitle(color: NSColor(red: 255, green: 255, blue: 255, alpha: 0.50), underline: true)
    }

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
        // Ändere die Textfarbe zu Blau und füge Unterstreichung hinzu
        updateTitle(color: NSColor(red: 76/255, green: 76/255, blue: 76/255, alpha: 1), underline: true)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        // Setze die Textfarbe zurück auf Schwarz ohne Unterstreichung
        updateTitle(color: NSColor(red: 255, green: 255, blue: 255, alpha: 0.50), underline: true)
    }

    // Hilfsmethode, um die Textfarbe und Unterstreichung des Buttons zu ändern
    private func updateTitle(color: NSColor, underline: Bool) {
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        ]
        
        if underline {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        self.attributedTitle = NSAttributedString(string: self.title, attributes: attributes)
    }
}
