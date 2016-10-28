//
//  NXMineView.swift
//  NXMines
//
//  Created by Sebestyén Gábor on 2014.06.22.
//
//

import Cocoa


typealias Field = (Int, Int)

func +( x : Field, y : Field ) -> Field {
    return ( x.0 + y.0 , x.1 + y.1 )
}


let Neighbors : [Field] = [
    (-1,-1), (0,-1), (1,-1),
    (-1,0),          (1,0),
    (-1,1),  (0,1),  (1,1)
]



class NXMineView : NSView, NSTextDelegate {
    // outlets
    @IBOutlet var startButton : NSButton!

    @IBOutlet var bombDisplay : NSTextField!
    @IBOutlet var timeDisplay : NSTextField!

    @IBOutlet var scorePanel : NSPanel!

    @IBOutlet var name0 : NSTextField!
    @IBOutlet var name1 : NSTextField!
    @IBOutlet var name2 : NSTextField!

    @IBOutlet var time0 : NSTextField!
    @IBOutlet var time1 : NSTextField!
    @IBOutlet var time2 : NSTextField!


    enum GameMode {
        case BEGINNER, MEDIUM, EXPERT
    }
    

    static let SETUP = [
        // mode -> title, width, height, n of bombs to hide
        GameMode.BEGINNER : (title:"Beginner", cols:10, rows:10, bombs:10),
        GameMode.MEDIUM : (title:"medium", cols:20, rows:20, bombs:60),
        GameMode.EXPERT : (title:"Expert", cols:20, rows:20, bombs:100)
    ]

    struct GameSetup {
        var mode : GameMode
        var fh : UInt
        var fw : UInt
        var bombs: UInt
        
        var fc : UInt {
            get {
                return fh*fw
            }
        }
    }


    // internal instance vars
    var fieldsList : [MineButton] = []
    var game : GameSetup?
    // number of uncovered blocks
    var maxspc : UInt = 0
    
    var isRunning = false

    var	timer : NSTimer?
    var temp = 0


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

    
    @IBAction func startGame(sender:AnyObject?) {
        
        // kill timer
        if let t = timer {
            t.invalidate()
            timer = nil
        }
        
        self.window!.autodisplay = false
        
        // reset mine field
        for mine in fieldsList {
            mine.hasBomb = false
            mine.flagged = false
            mine.visited = false
            
            mine.enabled = true
            mine.image = NSImage(named: "brick.tiff")
        }
        
        // distribute bombs
        var rnd = 0
        for _ in 0..<game!.bombs {
            repeat {
                rnd = Int( arc4random_uniform( UInt32(game!.fc) ) );
            } while fieldsList[ rnd ].hasBomb;
            
            fieldsList[ rnd ].hasBomb = true
        }

        for bomb in fieldsList {
            doCalcBombs(bomb)
        }
        
        
        self.window!.autodisplay = true
        
        maxspc = game!.fc // set max clickable field
        temp = 0; // reset time counter
        
        // update displays
        bombDisplay.integerValue = Int(game!.bombs)
        timeDisplay.integerValue = 0
        
        // let it go
        isRunning = true
        
    }
    
    
    // Left Click Handler
    @IBAction func buttonPushed(sender:MineButton) {
        guard isRunning else {
            return
        }
        
        if sender.pushed {
            return
        }
        
        // check clicked field
        if sender.hasBomb {
            // KA-BOOOM
            for bomb in fieldsList {
                bomb.enabled = false
                
                bomb.doUpdateImage()
            }
            
            // mark the clicked field as false
            sender.image = NSImage(named: "brickPushedAndFalseBomb.tiff")
            NSBeep()
            
            // lose
            endGame(false)
            
        } else {
            // explore clicked area
            doUncover( sender.pos )
            
            if checkWinState() {
                // Win !!!
                endGame(true)
            } else if timer == .None {
                // start ticking
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
    
    
    // Right Click Handler
    @IBAction func rightButtonPushed(field:MineButton) {
        guard isRunning else {
            return
        }

        if field.visited {
            return
        }
        
        // swap flag
        field.doSwapFlag()
        
        bombDisplay.integerValue += field.flagged ? 1 : -1
        
        
        if checkWinState() {
            // Win !!!
            endGame(true)
        }
    }



    
    
    func initGame(mode : GameMode) {
        isRunning = false

        // remove all bomb buttons
        for btn in fieldsList {
            btn.removeFromSuperview()
        }
        fieldsList.removeAll()


        // initialize table
        if let s = NXMineView.SETUP[mode] {
            game = GameSetup(mode: mode, fh: UInt(s.cols), fw: UInt(s.rows), bombs: UInt(s.bombs))
            
            // set window title
            self.window?.title = s.title
            
            // -- //
            self.window?.autodisplay = false

            // Resize everything
            if let aRect = self.window?.frame {
                // resize window
                self.window!.setFrame(
                    NSRect(
                        origin: aRect.origin,
                        size: CGSize(width: 16 + CGFloat(game!.fw)*18, height: 16 + 64 + CGFloat(game!.fh)*18)
                    ),
                    display: true
                )

                // resize minefield view
                self.frame = NSRect(
                    origin: self.frame.origin,
                    size: CGSize(width: CGFloat(game!.fw)*18, height: CGFloat(game!.fh)*18)
                )
            }
            
            // enforce manual UI update
            self.window!.display()


            fieldsList = [MineButton]()
            
            
            for var j in 0..<Int(game!.fw) {
                for var i in 0..<Int(game!.fh) {
                    let obj = MineButton(frame: NSRect(x: i*18, y:j*18, width:18, height: 18))

                    obj.pos = (i,j)
                    
                    // obj.target = self
                    // obj.action = Selector("buttonPushed:")

                    self.addSubview(obj)
                    fieldsList.append(obj)
                }
            }
            
            self.window!.display()

            // re-enable auto UI update
            self.window!.autodisplay = true
            
            // --- //
            
            
        }
    }


    // @private
    func endGame(win: Bool) {
        // terminate current game session
        isRunning = false
        
        // stop timer
        if let t = timer {
            t.invalidate()
            timer = nil
        }
        
        
        // status = win ?
        if win {
            var field1 : NSTextField
            var field2 : NSTextField
            switch game!.mode {
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
            
            // time beat
            if temp < field1.integerValue {
                let panel = NSAlert()
                
                panel.messageText = "You Won!!"
                panel.informativeText = "And you beat the best time!"
                panel.addButtonWithTitle("OK")
                
                panel.runModal()
                
                
                field1.integerValue = temp
                field2.editable = true
                
                scorePanel.makeKeyAndOrderFront(self)
            } else {
                let panel = NSAlert()
                
                panel.messageText = "You Won!!"
                panel.informativeText = "Although best time is not beaten"
                panel.addButtonWithTitle("OK")
                
                panel.runModal()
            }
            
        } else {
            // Player failed, do nothings
        }
    }


    // NSTimer callback
    func tick(aTimer : NSTimer) {
        if temp < 1000 {
            temp++
            
            timeDisplay!.integerValue = temp
        }
    }


    static let Neighbors : [Field] = [
        (-1,-1), (0,-1), (1,-1),
        (-1,0),          (1,0),
        (-1,1),  (0,1),  (1,1)
    ]


    func doUncover(f : Field) {
        if let bomb = fieldAt(f) {
            doUncover(bomb)
        }
    }

    func doUncover(field : MineButton) {
        if field.visited || field.flagged {
            return
        }

        // Mark field
        field.enabled = false
        field.visited = true

        // set bomb image accordingly
        field.doUpdateImage()

        maxspc--

        // Phase two, visit neighbor fields
        if bomb.bombsAround == 0 {
            for r in NXMineView.Neighbors {
                if let neighbor = bombAt( (bomb.pos.0 + r.0, bomb.pos.1 + r.1) ) {
                    if !neighbor.hasBomb {
                        doUncover( neighbor )
                    }
                }
            }
        }
    }


    /**
     * Count surrounding bombs
     */
    func doCalcBombs(bomb : MineButton) {
        // count surrounding bombs
        var count : UInt = 0

        for r in NXMineView.Neighbors {
            if let b = bombAt( (bomb.pos.0 + r.0, bomb.pos.1 + r.1) ) {
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
            name0.stringValue = v
            time0.integerValue = ud.integerForKey("time0")
        } else {
            name0.stringValue = "Choler"
            time0.integerValue = 999
        }

    
        if let v = ud.stringForKey("name1") {
            name1.stringValue = v
            time1.integerValue = ud.integerForKey("time1")
        } else {
            name1.stringValue = "Sang"
            time1.integerValue = 999
        }

    
        if let v = ud.stringForKey("name2") {
            name2.stringValue = v
            time2.integerValue = ud.integerForKey("time2")
        } else {
            name2.stringValue = "Melan"
            time2.integerValue = 999
        }
    }


    func saveScores() {
        let ud = NSUserDefaults.standardUserDefaults()

        ud.setObject(name0!.stringValue, forKey: "name0")
        ud.setInteger(time0!.integerValue, forKey: "time0")

        ud.setObject(name1!.stringValue, forKey: "name1")
        ud.setInteger(time1!.integerValue, forKey: "time1")

        ud.setObject(name2!.stringValue, forKey: "name2")
        ud.setInteger(time2!.integerValue, forKey: "time2")
    }


    func resetScores() {
        // TODO: complete function
    }
    
    
    
    /** Find and return field in mine field */
    func fieldAt( f : Field ) -> MineButton? {
        if f.0 >= 0 && f.0 < Int(game!.fw) && f.1 >= 0 && f.1 < Int(game!.fh) {
            return fieldsList[f.0+(f.1*Int(game!.fw))]
        }
        return .None
    }




    func checkWinState() -> Bool {
        // Special case
        // (visited fields).size == FIELDS.size - bombs.count => LOSE
        let nCovered = Int(game!.fc) - fieldsList.filter{ $0.visited }.count
        if nCovered == Int(game!.bombs) {
            return true
        }

        if bombDisplay.integerValue == 0 {

            let nBombs : UInt = fieldsList
                .filter { $0.flagged && $0.hasBomb }
                .reduce(0) { (sum,n) in sum+1 }

            if nBombs == game!.bombs {
                return true
            }
        }
        
        return false
    }
    

    // MARK: == NSTextDelegate protocol ==
    func textDidEndEditing(notification: NSNotification) {
        // FIXME: never invoked!
        if let target : NSTextField = notification.object as? NSTextField {
            target.editable = false
        }
    }
}
