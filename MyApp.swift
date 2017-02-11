//
//  MyApp.swift
//  NXMines
//
//  Created by Sebestyén Gábor on 2014.06.21.
//
//

import Cocoa

@NSApplicationMain
class MyApp : NSObject, NSApplicationDelegate
{
    @IBOutlet var mineView : NXMineView!

    func applicationShouldTerminate(_ app : NSApplication) -> NSApplicationTerminateReply {

        // save game scores
        mineView.saveScores()

        // let the app terminate now
        return NSApplicationTerminateReply.terminateNow
    }
}
