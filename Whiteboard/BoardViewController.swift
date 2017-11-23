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

class BoardViewController: UIViewController, MCBrowserViewControllerDelegate, CloseMenu, UITextFieldDelegate {
    func closeMenu() {
        emojiTextField.endEditing(false)
        UIView.animate(withDuration: 0.4, animations: {
            self.MainMenuHeight.constant = -148
            self.MainMenuButton.transform = CGAffineTransform(rotationAngle: 0)
            self.view.layoutIfNeeded()
        })
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textSelected = true
    }
    var textSelected:Bool!
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.25, animations: {
            self.MainMenuHeight.constant = 0
            self.MainMenuButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            self.view.layoutIfNeeded()
        })
        
        textField.resignFirstResponder()
        return true
    }
    @IBOutlet weak var emojiTextField: UITextField!
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        mpcHandler.browser.dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var MainMenuButton: UIButton!
    @IBOutlet weak var MainMenuHeight: NSLayoutConstraint!
    @IBAction func thickness(_ sender: UIButton) {
        let formatLine = LineFormatSettings.sharedInstance
        switch sender.tag{
        case 0:
            formatLine.width = 3.0
            break
        case 1:
            formatLine.width = 5.0
            break
        default:
            formatLine.width = 8.0
            break
        }
    }
    @IBAction func color(_ sender: UIButton) {
        print(sender.tag)
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
    }

    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var lineImageView: UIImageView!
    
    let viewModel = BoardViewModel()
    let disposeBag = DisposeBag()
    var mpcHandler = MPCHandler.sharedInstance
    
    @IBAction func Menu(_ sender: UIButton) {
        
        if MainMenuHeight.constant == -148{
            UIView.animate(withDuration: 0.5, animations: {
                self.MainMenuHeight.constant = 0
                self.MainMenuButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.view.layoutIfNeeded()
            })
        } else if MainMenuHeight.constant == 0{
            UIView.animate(withDuration: 0.5, animations: {
                self.MainMenuHeight.constant = -148
                self.MainMenuButton.transform = CGAffineTransform(rotationAngle: 0)
                self.view.layoutIfNeeded()
            })
        } else {
            emojiTextField.endEditing(false)
            UIView.animate(withDuration: 0.35, animations: {
                self.MainMenuHeight.constant = -148
                self.MainMenuButton.transform = CGAffineTransform(rotationAngle: 0)
                self.view.layoutIfNeeded()
            })
        }
        
    }
    @IBAction func Add(_ sender: Any) {
        if mpcHandler.session != nil{
            mpcHandler.setupBrowser()
            mpcHandler.browser.delegate = self
            self.present(mpcHandler.browser, animated: true, completion: nil)
        }
    }
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        MainMenuHeight.constant = -148
        mpcHandler.setupPeerWithDisplayName(displayName: UIDevice.current.name)
        mpcHandler.setupSession()
        mpcHandler.advertiseSelf(advertise: true)
        mpcHandler.setupSubscribe()
        
        
        
        drawView.closeMenuDelagate = self
        drawView.clearsContextBeforeDrawing = true
        drawView.viewModel = self.viewModel
        
        self.viewModel.lineImage.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { lineImage in
                UIView.transition(with: self.view,
                                  duration: 0.25,
                                  options: UIViewAnimationOptions.transitionCrossDissolve,
                                  animations: { self.lineImageView.image = lineImage },
                                  completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

class LineFormatSettings {
    static let sharedInstance = LineFormatSettings()
    
    var width : CGFloat = 5.0
    var cap = CGLineCap.round
    var color = LineColor.blue
}



