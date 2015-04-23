//
//  MineButton.swift
//  NXMines
//
//  Created by Sebestyén Gábor on 2014.06.22..
//
//

import Cocoa

class MineButton : NSButton
{
    var pos_x = 0;
    var pos_y = 0;

    var hasBomb = false
    var flagged = false
    var visited = false
    
    var bombsAround : UInt = 0

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // decorate button
        setButtonType(NSButtonType.MomentaryChangeButton)
        self.image = NSImage(named: "brick.tiff")
        self.alternateImage = NSImage(named: "brickPushed.tiff")
        self.bordered = false
    }

    override func mouseDown(theEvent: NSEvent) {
        (self.superview as! NXMineView).buttonPushed(self)
    }

    override func rightMouseUp(theEvent: NSEvent) {
        (self.superview as! NXMineView).rightButtonPushed(self)
    }
}
