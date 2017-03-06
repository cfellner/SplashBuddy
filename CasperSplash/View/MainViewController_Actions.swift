//
//  MainViewController_Actions.swift
//  CasperSplash
//
//  Created by Francois Levaux on 02.03.17.
//  Copyright © 2017 François Levaux-Tiffreau. All rights reserved.
//

import Cocoa

extension MainViewController {
    
    
    /// Do the initial setup of the view
    func setupInstalling() {
        indeterminateProgressIndicator.startAnimation(self)
        indeterminateProgressIndicator.isHidden = false
        
        installingLabel.stringValue = "Installing…"
        
        statusLabel.stringValue = ""
        
        continueButton?.isEnabled = false
    }
    
    
    /// One or more applications failed to install
    func errorWhileInstalling() {
        indeterminateProgressIndicator.isHidden = true
        installingLabel.stringValue = ""
        continueButton?.isEnabled = true
        statusLabel.textColor = .red
        
        let _failedSoftwareArray = SoftwareArray.sharedInstance.failedSoftwareArray()
        
        if _failedSoftwareArray.count == 1 {
            
            if let failedDisplayName = _failedSoftwareArray[0].displayName {
            statusLabel.stringValue = String.localizedStringWithFormat(NSLocalizedString("%@ failed to install. Support has been notified.", comment: "A specific application failed to install"), failedDisplayName)
            } else {
                statusLabel.stringValue = NSLocalizedString("An application failed to install. Support has been notified.", comment: "One (unnamed) application failed to install")
            }
            
            
        } else {
            statusLabel.stringValue = NSLocalizedString("Some applications failed to install. Support has been notified.", comment: "More than one application failed to install")
        }
        
    }

    
    /// All critical applications were installed
    func canContinue() {
        continueButton?.isEnabled = true
    }
    
    
    /// All applications were installed successfuly
    func doneInstalling() {
        indeterminateProgressIndicator.isHidden = true
        installingLabel.stringValue = ""
        statusLabel.textColor = .green
        statusLabel.stringValue = NSLocalizedString("All applications were installed. Please click continue.", comment: "All applications were installed. Please click continue.")
    }
    
    
    /// All applications were installed (successfuly or not)
    func allDone() {
        
        // If Continue Button is hidden, application will quit after 5 seconds
        
        if Preferences.sharedInstance.hideContinueButton {
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(MainViewController.quitApplication), userInfo: nil, repeats: false)
        }
    }
    
    func quitApplication() {
        NSApplication.shared().terminate(self)
    }

    
    
    
}
