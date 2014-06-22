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
    init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // decorate button
        setButtonType(NSButtonType.MomentaryChangeButton)
        self.image = NSImage(named: "brick.tiff")
        self.alternateImage = NSImage(named: "brickPushed.tiff")
        self.bordered = false;
    }

    override func rightMouseUp(theEvent: NSEvent!) {
        (self.superview as NXMineView).rightButtonPushed(self)
    }
}
