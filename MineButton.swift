//
//  MineButton.swift
//  NXMines
//
//  Created by Sebestyén Gábor on 2014.06.22.
//
//

import Cocoa

class MineButton : NSButton
{
    var pos : Field = (0,0)

    /**
     * This field conceals a bomb
     */
    var hasBomb = false

    /**
     * Is marker flag placed?
     */
    var flagged = false

    /**
     * Visited == field is uncovered
     */
    var visited = false
    
    var pushed : Bool {
        get {
            return flagged || visited
        }
    }

    /**
     * Count of bombs hiddeb by the adjacent fields
     */
    var bombsAround : UInt = 0

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // decorate button
        setButtonType(NSButtonType.MomentaryChangeButton)
        
        image = NSImage(named: "brick.tiff")
        alternateImage = NSImage(named: "brickPushed.tiff")
        bordered = false
    }

    override func mouseDown(theEvent: NSEvent) {
        (self.superview as! NXMineView).buttonPushed(self)
    }

    override func rightMouseUp(theEvent: NSEvent) {
        (self.superview as! NXMineView).rightButtonPushed(self)
    }
    
    
    /**
     * Update field status after click
     */
    func doUpdateImage() {
        self.image = hasBomb
            ? NSImage(named:"brickPushedAndBomb.tiff")
            : bombsAround > 0
                ? NSImage(named: "brick\(bombsAround).tiff")
                : NSImage(named: "brickPushed.tiff")

    }


    /**
     * Mark field with flag or remove
     * This method is called when field gets right mouse click
     */
    func doSwapFlag() {
        if flagged {
            flagged = false
            enabled = true
            image = NSImage(named:"brick.tiff")
        } else {
            flagged = true
            enabled = false
            image = NSImage(named:"brickAndFlag.tiff")
        }

    }
    
    
}
