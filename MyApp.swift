//
//  MyApp.swift
//  NXMines
//
//  Created by Sebestyén Gábor on 2014.06.21..
//
//

import Cocoa

class MyApp : NSObject, NSApplicationDelegate
{
    // @IBOutlet var gameWindow : NSWindow;
    @IBOutlet var mineView : NXMineView;


    // MARK: NSApplicationDelegate

    func applicationDidFinishLaunching(notification: NSNotification) {
        // gameWindow.makeKeyAndOrderFront(self)
    }

    
    func applicationShouldTerminate(app : NSApplication) -> NSApplicationTerminateReply {

        // save game scores
        mineView.saveScores()

        // let the app terminate now
        return NSApplicationTerminateReply.TerminateNow
    }
}