//
//  NXMineView.swift
//  NXMines
//
//  Created by Sebestyén Gábor on 2014.06.22..
//
//

import Cocoa

class NXMineView : NSView, NSTextDelegate {
    // outlets
    @IBOutlet var startButton : NSButton?

    @IBOutlet var bombDisplay : NSTextField?
    @IBOutlet var timeDisplay : NSTextField?

    @IBOutlet var scorePanel : NSPanel?

    @IBOutlet var name0 : NSTextField?
    @IBOutlet var name1 : NSTextField?
    @IBOutlet var name2 : NSTextField?

    @IBOutlet var time0 : NSTextField?
    @IBOutlet var time1 : NSTextField?
    @IBOutlet var time2 : NSTextField?

    let imageNames = [
        "brickPushed.tiff",
        "brick1.tiff",
        "brick2.tiff",
        "brick3.tiff",
        "brick4.tiff",
        "brick5.tiff",
        "brick6.tiff",
        "brick7.tiff",
        "brick8.tiff"
    ]

    enum GameMode {
        case BEGINNER, MEDIUM, EXPERT
    }

    // internal instance vars
    var fieldsList : [MineButton] = [MineButton]()
    var gameMode : GameMode = .BEGINNER
    var isRunning = false
    var	timer : NSTimer?
    var bombs = 0
    var fw = 0, fh = 0
    var fc = 0
    // number of uncovered blocks
    var maxspc = 0
    var temp = 0
    
    var actTextField : NSTextField?
    
    var showAll = false

    // override NSResponder's acceptsFirstResponder property
    override var acceptsFirstResponder : Bool {
        get { return true }
    }

    deinit {
        // kill timer
        if let t = timer {
            t.invalidate()
        }
    }
    
    
    // get initialized when spawning from NIB file
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadScores()

        initGame(GameMode.BEGINNER)
    }

    

    
    // MARK: == Actions ==
    
    @IBAction func setBeginner(sender: AnyObject) {
        initGame(GameMode.BEGINNER)
    }

    @IBAction func setMedium(sender: AnyObject) {
        initGame(GameMode.MEDIUM)
    }

    @IBAction func setExpert(sender: AnyObject) {
        initGame(GameMode.EXPERT)
    }

    let setup = [
        // mode -> title, width, height, n of bombs to hide
        GameMode.BEGINNER : (title:"Beginner", cols:10, rows:10, bombs:10),
        GameMode.MEDIUM : (title:"medium", cols:20, rows:20, bombs:60),
        GameMode.EXPERT : (title:"Expert", cols:20, rows:20, bombs:100)
    ]



    func initGame(mode : GameMode) {
        if isRunning {
            isRunning = false
        }
        
        // remove all bomb buttons
        for btn in fieldsList {
            btn.removeFromSuperview()
        }
        fieldsList.removeAll()


        // set actual game mode
        gameMode = mode

        // initialize table
        if let s = setup[gameMode] {
            // set window title
            self.window?.title = s.title
            
            // -- //
            self.window?.autodisplay = false

            bombs = s.bombs
            (fw, fh, fc) = ( s.cols, s.rows, s.cols*s.rows)

            // Resize everything
            if let aRect = self.window?.frame {
                // resize window
                self.window?.setFrame(
                    NSRect(
                        origin: aRect.origin,
                        size: CGSize(width: 16 + CGFloat(fw)*18, height: 16 + 64 + CGFloat(fh)*18)
                    ),
                    display: true
                )

                // resize minefield view
                self.frame = NSRect(
                    origin: self.frame.origin,
                    size: CGSize(width: CGFloat(fw)*18, height: CGFloat(fh)*18)
                )
            }
            
            // enforce manual UI update
            self.window?.display()


            fieldsList = [MineButton]()
            for (var j=0; j<s.rows; j++) {
                 for (var i=0; i<s.cols; i++) {
                    let obj = MineButton(frame: NSRect(x: i*18, y:j*18, width:18, height: 18))

                    obj.pos_x = i
                    obj.pos_y = j

                    // obj.target = self
                    // obj.action = Selector("buttonPushed:")

                    self.addSubview(obj)
                    fieldsList.append(obj)
                }
            }
            
            self.window?.display()

            // re-enable auto UI update
            self.window?.autodisplay = true
            
            // --- //
            
            
        }
    }


    func endGame(win: Bool) {
        if !isRunning {
            return
        }
        
        isRunning = false
        
        // stop timer
        if let t = timer {
            t.invalidate()
            timer = nil
        }
        
        
        
        if win {
            var field1 : NSTextField
            var field2 : NSTextField
            switch gameMode {
            case .BEGINNER:
                field1 = time0!
                field2 = name0!
            case .MEDIUM:
                field1 = time1!
                field2 = name1!
            case .EXPERT:
                field1 = time2!
                field2 = name2!
            }
            
            // better time achieved
            if temp < field1.integerValue {
                let panel = NSAlert()
                
                panel.messageText = "You Won!!"
                panel.informativeText = "And you beat the best time!"
                panel.addButtonWithTitle("OK")
                
                panel.runModal()
                
                
                field1.integerValue = temp
                field2.editable = true
                
                scorePanel?.makeKeyAndOrderFront(self)
                // actTextField = field2
            }
            
        } else {
            let panel = NSAlert()
            
            panel.messageText = "You Blasted!"
            panel.informativeText = "Hmmm, you found a lost mine..."
            panel.addButtonWithTitle("Try Again")

            panel.runModal()
        }
    }
    

    // NSTimer callback
    func tick(aTimer : NSTimer) {
        if temp < 1000 {
            temp++
            
            timeDisplay?.integerValue = temp
        }
    }

    let d = [ (-1,-1), (0,-1), (1,-1), (-1,0), (1,0), (-1,1), (0,1), (1,1) ]

    func doUncover(px : Int,  _ py : Int) {
        if let bomb = bombAtX(px, Y: py) {
            doUncover(bomb)
        }
    }

    func doUncover(bomb : MineButton) {
        // TODO: count bombs around actual position
        if bomb.visited || bomb.flagged {
            return
        }

        // Phase one .. mark field
        
        // set bomb image accordingly
        bomb.image = NSImage(named:imageNames[Int(bomb.bombsAround)])
        bomb.enabled = false
        
        bomb.visited = true
        maxspc--


        // Phase two, visit neighbor fields
        if bomb.bombsAround == 0 {
            for r in d {
                if let neighbor = bombAtX(bomb.pos_x+r.0, Y: bomb.pos_y+r.1) {
                    if !neighbor.hasBomb {
                        doUncover( neighbor )
                    }
                }
            }
        }
    }


    func doCalcBombs(bomb : MineButton) {
        // count surrounding bombs
        var count : UInt = 0

        for r in d {
            if let b = bombAtX(bomb.pos_x+r.0, Y: bomb.pos_y+r.1) {
                if b.hasBomb {
                    count++
                }
            }
        }
        bomb.bombsAround = count
    }



    // MARK: Scores
    func loadScores() {
        let ud = NSUserDefaults.standardUserDefaults()
        
        if let v = ud.stringForKey("name0") {
            name0?.stringValue = ud.stringForKey("name0")
            time0?.integerValue = ud.integerForKey("time0")
        } else {
            name0?.stringValue = "Choler"
            time0?.integerValue = 999
        }

    
        if let v = ud.stringForKey("name1") {
            name1?.stringValue = ud.stringForKey("name1")
            time1?.integerValue = ud.integerForKey("time1")
        } else {
            name1?.stringValue = "Sang"
            time1?.integerValue = 999
        }

    
        if let v = ud.stringForKey("name2") {
            name2?.stringValue = ud.stringForKey("name2")
            time2?.integerValue = ud.integerForKey("time2")
        } else {
            name2?.stringValue = "Melan"
            time2?.integerValue = 999
        }
    }


    func saveScores() {
        let ud = NSUserDefaults.standardUserDefaults()

        if let val = name0?.stringValue {
            ud.setObject(val, forKey: "name0")
        }
        if let val = time0?.integerValue {
            ud.setInteger(val, forKey: "time0")
        }

        if let val = name1?.stringValue {
            ud.setObject(val, forKey: "name1")
        }
        if let val = time1?.integerValue {
            ud.setInteger(val, forKey: "time1")
        }

        if let val = name2?.stringValue {
            ud.setObject(val, forKey: "name2")
        }
        if let val = time2?.integerValue {
            ud.setInteger(val, forKey: "time2")
        }
    }


    func resetScores() {
        // TODO: complete function
    }
    
    
    
    // Find and return bomb at position
    func bombAtX(x : Int, Y y : Int) -> MineButton? {
        if x >= 0 && x < fw && y >= 0 && y < fh {
            return fieldsList[x+(y*fw)]
        }
        return .None
    }


    @IBAction func startGame(sender:AnyObject?) {

        // kill timer
        if let t = timer {
            t.invalidate()
            timer = nil
        }

        self.window?.autodisplay = false

        // reset mine field
        for mine in fieldsList {
            // tag = 0
            mine.hasBomb = false
            mine.flagged = false
            mine.visited = false
            
            mine.enabled = true
            mine.image = NSImage(named: "brick.tiff")
        }
        
        // distribute bombs
        var rnd = 0
        for (var i=0; i<bombs ; i++) {
            do {
                rnd = Int( arc4random_uniform( UInt32(fc) ) );
            } while fieldsList[ rnd ].hasBomb;
            
            fieldsList[ rnd ].hasBomb = true
            // println("Bomb was put here \(fieldsList[rnd].pos_x),\(fieldsList[rnd].pos_y)")
        }

        for bomb in fieldsList {
            doCalcBombs(bomb)
        }
        
        
        self.window?.autodisplay = true

        maxspc = fc // set max clickable field
        temp = 0; // reset time counter

        // FIXME: is this field is used anymore?
        actTextField = nil

        // update displays
        bombDisplay?.integerValue = bombs
        timeDisplay?.integerValue = 0

        // let it go
        isRunning = true
        
    }
    
    
    @IBAction func buttonPushed(sender:MineButton) {
        if !isRunning {
            return
        }

        if sender.flagged || sender.visited {
            return
        }

        // check clicked field
        if sender.hasBomb {
            // KA-BOOOM
            for bomb in fieldsList {
                bomb.enabled = false
                if bomb.hasBomb {
                    bomb.image = NSImage(named:"brickPushedAndBomb.tiff")
                } else {
                    bomb.image = NSImage(named:imageNames[Int(bomb.bombsAround)])
                }
            }

            // mark the clicked field as false
            sender.image = NSImage(named: "brickPushedAndFalseBomb.tiff")
            NSBeep()

            // lose
            endGame(false)
            
        } else {
            // explore clicked area
            doUncover(sender.pos_x, sender.pos_y)

            if checkWinState() {
                // Win !!!
                endGame(true)
            } else if timer == .None {
                timer = NSTimer.scheduledTimerWithTimeInterval(
                    1,
                    target: self,
                    selector: "tick:",
                    userInfo: nil,
                    repeats: true)
                NSBeep()
            }
        }
    }



    @IBAction func rightButtonPushed(sender:MineButton) {
        if !isRunning {
            return
        }
        
        if sender.visited {
            return
        }
        
        // swap flag
        if sender.flagged {
            sender.flagged = false
            sender.enabled = true
            sender.image = NSImage(named:"brick.tiff")
            
            bombDisplay?.integerValue += 1
        } else {
            sender.flagged = true
            sender.enabled = false
            sender.image = NSImage(named:"brickAndFlag.tiff")

            bombDisplay?.integerValue -= 1
        }

        if checkWinState() {
            // Win !!!
            endGame(true)
        }
    }


    func checkWinState() -> Bool {
        if maxspc == bombs {
            return true
        }
        
        if bombDisplay?.integerValue == 0 {
            // all flags set out
            var k = 0
            for b in fieldsList {
                if b.flagged && b.hasBomb {
                    k++
                }
            }
            
            if k == bombs {
                return true
            }
        }
        
        return false
    }
    

    // MARK: == NSTextDelegate protocol ==
    func textDidEndEditing(notification: NSNotification!) {
        // FIXME: never invoked!
        if let target : NSTextField = notification.object as? NSTextField {
            target.editable = false
        }
    }
}
