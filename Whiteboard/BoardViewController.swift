//
//  BoardViewController.swift
//  Whiteboard
//
//  Created by Andrew on 2017-11-15.
//  Copyright © 2017 hearthedge. All rights reserved.
//

import UIKit
import RxSwift
import MultipeerConnectivity

class LineFormatSettings {
    static let sharedInstance = LineFormatSettings()
    
    var width : CGFloat = 5.0
    //var cap = CGLineCap.round
    var cap = CGLineCap.square
    var color = LineColor.blue
}

class BoardViewController: UIViewController, MCBrowserViewControllerDelegate, CloseMenu, UITextFieldDelegate {
    
    //MARK: Properties / Outlets
    let viewModel = BoardViewModel()
    let disposeBag = DisposeBag()
    var mpcHandler = MPCHandler.sharedInstance
    var textSelected:Bool!
    
    @IBOutlet weak var emojiTextField: UITextField!
    @IBOutlet weak var MainMenuButton: UIButton!
    @IBOutlet weak var MainMenuHeight: NSLayoutConstraint!
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var lineImageView: UIImageView!
    @IBOutlet var ColorButtons: [UIButton]!
    
    //MARK: Load
    override func viewDidLoad() {
        super.viewDidLoad()
        updateColorButtons()
        setUpMPC()
        setUpModel()
        setUpMenu()
    }
    
    //MARK:Setup
    func updateColorButtons(){
        for button in ColorButtons{
            button.backgroundColor = LineElement(line: Line(), width: 69.69, cap: .butt, color: LineColor(rawValue: button.tag)!).drawColor //sooo janky
        }
    }
    func setUpMPC(){
        mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        mpcHandler.setupSession()
        mpcHandler.advertiseSelf(advertise: true)
        mpcHandler.setupSubscribe()
    }
    func setUpModel(){
        self.drawView.closeMenuDelagate = self
        self.drawView.clearsContextBeforeDrawing = true
        self.drawView.viewModel = self.viewModel
        
        self.viewModel.recieveLine(self.drawView.lineStream)
        
        self.viewModel.lineImage.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { lineImage in
                self.lineImageView.image = lineImage
//                UIView.transition(with: self.view,
//                                  duration: 0,
//                                  options: UIViewAnimationOptions.transitionCrossDissolve,
//                                  animations: {  },
//                                  completion: nil)
            }).disposed(by: disposeBag)
    }
    func setUpMenu(){
        MainMenuButton.setTitleColor(LineElement(line: Line(), width: 0, cap: .butt, color: LineFormatSettings.sharedInstance.color).drawColor, for: UIControlState.normal) //jankness
        MainMenuButton.titleLabel?.font = MainMenuButton.titleLabel?.font.withSize(40.0)
        MainMenuHeight.constant = -160
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
    }
    
    //MARK: Actions
    
    @IBAction func thickness(_ sender: UIButton) {
        let formatLine = LineFormatSettings.sharedInstance
        switch sender.tag{
        case 0:
            formatLine.width = 3.0
            MainMenuButton.titleLabel?.font = MainMenuButton.titleLabel?.font.withSize(24.0)
            break
        case 1:
            formatLine.width = 5.0
            MainMenuButton.titleLabel?.font = MainMenuButton.titleLabel?.font.withSize(40.0)
            break
        default:
            formatLine.width = 11.0
            MainMenuButton.titleLabel?.font = MainMenuButton.titleLabel?.font.withSize(56.0)
            break
        }
    }
    
    @IBAction func color(_ sender: UIButton) {
        textSelected = false
        let formatLine = LineFormatSettings.sharedInstance
        switch sender.tag{
        case 0:
            formatLine.color = LineColor.black
        case 1:
            formatLine.color = LineColor.white
        case 2:
            formatLine.color = LineColor.red
        case 3:
            formatLine.color = LineColor.orange
        case 4:
            formatLine.color = LineColor.yellow
        case 5:
            formatLine.color = LineColor.green
        case 6:
            formatLine.color = LineColor.blue
        case 7:
            formatLine.color = LineColor.purple
        default:
            formatLine.color = LineColor.black
        }
        MainMenuButton.setTitleColor(LineElement(line: Line(), width: 0, cap: .butt, color: formatLine.color).drawColor, for: UIControlState.normal) //jankness
    }
    
    @IBAction func Add(_ sender: Any) {
        if mpcHandler.session != nil{
            mpcHandler.setupBrowser()
            mpcHandler.browser.delegate = self
            self.present(mpcHandler.browser, animated: true, completion: nil)
        }
    }
    
    @IBAction func Menu(_ sender: UIButton) {
        
        if MainMenuHeight.constant == -160{
            UIView.animate(withDuration: 0.5, animations: {
                self.MainMenuHeight.constant = 0
                self.MainMenuButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.view.layoutIfNeeded()
            })
        } else if MainMenuHeight.constant == 0{
            closeMenu()
        } else { //Keyboard Open
            emojiTextField.endEditing(false)
            closeMenu()
        }
    }
    
    //MARK: Close Menu Delegate
    func closeMenu() {
        emojiTextField.endEditing(false)
        UIView.animate(withDuration: 0.4, animations: {
            self.MainMenuHeight.constant = -160
            self.MainMenuButton.transform = CGAffineTransform(rotationAngle: 0)
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: TextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textSelected = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.25, animations: {
            self.MainMenuHeight.constant = 0
            self.MainMenuButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            self.view.layoutIfNeeded()
        })
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Browser View Controller Delegate
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        mpcHandler.browser.dismiss(animated: true, completion: nil)
    }

    //MARK: Keyboard Will Show
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.5, animations: {
                self.MainMenuHeight.constant = keyboardHeight
                self.MainMenuButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.view.layoutIfNeeded()
            })
        }
    }
}
