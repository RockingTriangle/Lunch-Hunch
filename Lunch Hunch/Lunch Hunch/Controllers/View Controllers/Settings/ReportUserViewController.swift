//
//  ReportUserViewController.swift
//  Lunch Hunch
//
//  Created by Jaymond Richardson on 6/23/21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class ReportUserViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var reportedUserNameTextField: UITextField!
    @IBOutlet weak var reportDescriptionTextView: UITextView!
    
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Properties
    public var uid : String?
    private let vm = AboutViewModel()
    
    //MARK: - Actions
    @IBAction func submitReportButtonTapped(_ sender: Any) {
        presentControllerReport()
    }
    
    //MARK: - Functions
    
    func presentControllerReport() { //take in a user?
        let alertController = UIAlertController(title: "Report User", message: "Why do you want to report this user?", preferredStyle: .actionSheet)
        let bullyingAction = UIAlertAction(title: "Bullying", style: .default) { (action) in
                
            //JWR Add report user functionality here...
            self.reportUser(uid: self.uid!) //JWR add to about screen to get uid?
            
                let successAlert = UIAlertController(title: "User Has Been Reported", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            }
            successAlert.addAction(okAction)
            self.present(successAlert, animated: true, completion: nil)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alertController.addAction(bullyingAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func sendReport() {
        print("user has been reported")

    }
    
    func reportUser(uid: String) { //JWR report user in about view
        FBNetworkRequest.shared.reportUser(uid: uid)
        print("User \(uid) has been reported")
    }

    
    
}//End of class



