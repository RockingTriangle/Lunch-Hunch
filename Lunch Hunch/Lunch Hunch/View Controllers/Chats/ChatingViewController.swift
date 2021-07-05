//
//  ChatingViewController.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class ChatingViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet var titleView        : UIView!
    @IBOutlet weak var titleLabel  : UILabel!
    @IBOutlet weak var statusLabel : UILabel!
    @IBOutlet weak var tableView   : UITableView!
    
    @IBOutlet weak var recordView  : UIView!
    @IBOutlet weak var prograssBar : UIProgressView!
    @IBOutlet weak var timeLabel   : UILabel!
    
    @IBOutlet weak var sendButton  : UIButton!
    @IBOutlet weak var hatButton   : UIButton!
    
    @IBOutlet weak var textView    : UITextView!
    @IBOutlet weak var BottomView  : UIVisualEffectView!
    @IBOutlet weak var parentactionStack: UIStackView!
    
    @IBOutlet weak var heightVisualView         : NSLayoutConstraint!
    @IBOutlet weak var bottomVisualView         : NSLayoutConstraint!
    @IBOutlet weak var heightConstraintOfStack  : NSLayoutConstraint!
    @IBOutlet weak var hatButtonOutlet          : UIButton!
    
    // MARK: - Properties
    private let button  = UIButton()
    public  var name    = String()
    public  var uid     = String()
    
    private let restaurantSearchVM  = RestaurantSearchModel.shared
    private let restaurantVoteVM    = RestaurantVoteModel.shared
    private let database            = FBDatabase.shared
    private var selectedCell        = Message()
    private let vm                  = ChatingViewModel()
    private var current             = 0.0
    
    private var heightKeyboard: CGFloat     = 0
    private var heightOfBottomView: CGFloat = 0
    private var keyboardWillShow            = false
    
    var ref : DatabaseReference!
    var myHatButtonStatus = HatStatus.open { didSet { enableHatButton() }}
    var yourWinner = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initUserVM()
        initMessageVM()
        initNotifications()
        ref = Database.database().reference()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.isEditable = false
        textView.resignFirstResponder()
        
        vm.endTyping(friendID: uid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        vm.checkBlocking(uid: uid)
        super.viewWillAppear(animated)
        textView.isEditable = true
    }
    
    deinit {
        removeNotifications()
        FBDatabase.shared.removewMessagesObserver(forUID: uid)
        vm.readMessages(friendID: uid)
    }
    
    // MARK:- Init user and messages View Models
    func initUserVM() {
        vm.updateBottomViewClosure = { [weak self] in
            guard let self = self else { return }
            self.vm.isFriendBlocked || self.vm.isYouBlocked ? self.hideBottomView() : self.showBottomView()
        }
        vm.updateUserInfoClosure = { [weak self] in
            guard let self = self else { return }
            self.titleLabel.text  = self.vm.friend?.name
            self.statusLabel.text = self.vm.friend?.status
        }
        vm.updateUserImageoClosure = { [weak self] in
            guard let self = self else { return }
            self.button.setImage(self.vm.friend_image, for: .normal)
        }
        vm.updateFriendStatusClosure = { [weak self] in
            guard let self = self else { return }
            self.statusLabel.text = self.vm.isTyping ? "Typing..." : self.vm.friend?.status
        }
        vm.updateChoosingClosure = { [weak self] in
            guard let self = self else { return }
            if (self.vm.friendsHatStatus == .poll || self.vm.friendsHatStatus == .rando) && self.myHatButtonStatus == .open {
                self.hatButton.setImage(self.setImage(self.vm.friendsHatStatus), for: .normal)
                self.vm.startChoosing(friendID: self.uid, status: self.vm.friendsHatStatus)
                self.myHatButtonStatus = self.vm.friendsHatStatus
            } else if self.vm.friendsHatStatus == .winner {
                self.vm.getThierPoints(friendID: self.uid)
            } else {
                self.hatButton.setImage(self.setImage(self.myHatButtonStatus), for: .normal)
            }
            self.enableHatButton()
        }
        vm.updateResetClosure = { [weak self] in
            guard let self = self else { return }
            if self.vm.shouldReset {
                self.vm.cleanUpFBDatabase(friendID: self.uid)
                self.cleanupLocalVariables()
            }
        }
        vm.fetchUserInfo(uid: uid)
        vm.detectFriendTyping(friendID: uid)
        vm.detectChoosing(friendID: uid)
        vm.detectRestaurants(friendID: uid)
    }
    
    func initMessageVM() {
        vm.reloadTableViewClosure = { [weak self] in
            guard let self = self else { return }
            if self.vm.isNew {
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [.init(row: 0, section: 0)], with: .automatic)
                self.tableView.endUpdates()
                self.vm.isNew = false
                self.vm.readMessages(friendID: self.uid)
            } else { self.tableView.reloadData() }
        }
        vm.fetchMessages(uid: uid)
    }
    
    // MARK:- Setup view
    private func initView() {
        updateBottomView()
        setupBottomView()
        setupRightButton()
        textView.text = "..."
        textView.textColor = .black
        sendButton.isEnabled = false
        
        let bottom = view.safeAreaInsets.top + 44 + 30
        tableView.contentInset = .init(top: 5, left: 0, bottom: bottom, right: 0)
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.estimatedRowHeight = 100
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.titleView = titleView
    }
    //---------------------------------------------------------------------------------------------
    private func setupBottomView() {
        textView.delegate = self
        textView.textContainerInset = .init(top: 7, left: 15, bottom: 7, right: 15)
        textView.layer.cornerRadius = 16
        textView.layer.masksToBounds = true
    }
    //---------------------------------------------------------------------------------------------
    private func setupRightButton() {
        button.translatesAutoresizingMaskIntoConstraints             = false
        button.layer.cornerRadius                                    = 15
        button.layer.masksToBounds                                   = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30).isActive  = true
        
        let lefButton = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = lefButton
        button.addTarget(self, action: #selector(imagePressed), for: .touchUpInside)
    }
    //---------------------------------------------------------------------------------------------
    @objc private func imagePressed() {
        if vm.isYouBlocked {
            let name: String = (vm.friend?.name)!
            Alert.showAlert(at: self, title: "You are blocked by \(name), You Can't show his profile", message: "")
        } else { performSegue(withIdentifier: "ChatingToAbout", sender: self) }
        
    }
    //---------------------------------------------------------------------------------------------
    func hideBottomView() {
        BottomView.isHidden = true
    }
    //---------------------------------------------------------------------------------------------
    func showBottomView() {
        BottomView.isHidden = false
    }
    
    // MARK:- Handle action buttons
    @IBAction func sendPressed(_ sender: UIButton) {
        if vm.isYouBlocked {
            let name: String = (vm.friend?.name)!
            Alert.showAlert(at: self, title: "You are blocked by \(name), You Can't show his profile", message: "")
        } else {
            vm.sendTextMessage(uid: uid, text: textView.text)
            textView.text = ""
            let size = CGSize(width: textView.frame.width, height: .infinity)
            let height = textView.sizeThatFits(size)
            heightVisualView.constant = CGFloat(height.height) + 20
            heightConstraintOfStack.constant = CGFloat(height.height)
            
            sender.isEnabled = false
            if vm.countOfCells != 0 {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: true)
            }
        }
    }

    //---------------------------------------------------------------------------------------------
    @IBAction func hatButtonTapped(_ sender: Any) {
        switch (myHatButtonStatus, vm.friendsHatStatus) {
        case (.open, .open):
            showChoosingAlert()
        case (.poll, .poll), (.rando, .rando):
            performSegue(withIdentifier: "toSearchSettingsVC", sender: self)
        case (.vote, .vote), (.vote, .winner), (.winner, .vote):
            performSegue(withIdentifier: "toVoteController", sender: self)
        case (.winner, .winner):
            self.vm.checkForWinner(friendID: self.uid)
            alertUserOf(self.vm.winner)
            return
        default:
            return
        }
    }
    
    //MARK: - FUNCTIONS
    func enableHatButton() {
        switch myHatButtonStatus{
        case .open:
            hatButton.isEnabled = (vm.friendsHatStatus == .open)
        case .poll:
            hatButton.isEnabled = (vm.friendsHatStatus == .poll   || vm.friendsHatStatus == .vote)
        case .rando:
            hatButton.isEnabled = (vm.friendsHatStatus == .rando  || vm.friendsHatStatus == .winner)
        case .vote:
            hatButton.isEnabled = (vm.friendsHatStatus == .vote   || vm.friendsHatStatus == .winner)
        case .winner:
            hatButton.isEnabled = (vm.friendsHatStatus == .winner || vm.friendsHatStatus == .open)
        }
    }
    
    func showChoosingAlert() {
        let alertController = UIAlertController(title: "Would you like this to be a poll or randomizer?", message: nil, preferredStyle: .alert)
        
        let pollAction = UIAlertAction(title: "Poll", style: .default) { _ in
            self.dismiss(animated: true) {
                self.vm.startChoosing(friendID: self.uid, status: .poll)
                self.myHatButtonStatus = .poll
                self.hatButton.setImage(self.setImage(.poll), for: .normal)
            }
        }
        
        let randomAction = UIAlertAction(title: "Randomize", style: .default) { _ in
            self.dismiss(animated: true) {
                self.vm.startChoosing(friendID: self.uid, status: .rando)
                self.myHatButtonStatus = .rando
                self.hatButton.setImage(self.setImage(.rando), for: .normal)
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(pollAction)
        alertController.addAction(randomAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func setImage(_ status: HatStatus) -> UIImage {
        switch status {
        case .open:
            return #imageLiteral(resourceName: "hatIcon")
        case .poll:
            return #imageLiteral(resourceName: "hatIconPoll")
        case .rando:
            return #imageLiteral(resourceName: "hatIconRando")
        case .vote:
            return #imageLiteral(resourceName: "logo")
        case .winner:
            return #imageLiteral(resourceName: "pin")
        }
    }
    
    func alertUserOf(_ winner: String) {
        let alert = UIAlertController(title: "Winner", message: winner, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.vm.ensureBothSeeWinner(friendID: self.uid)
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    // MARK:- Handling Keyboard with Notifications
    private func initNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBottomView), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func keyboardChangeFrame(_ notification: Notification?) {
        guard let info    = notification?.userInfo else { return }
        let duration      = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve         = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let startingFrame = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endingFrame   = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY        = endingFrame.origin.y - startingFrame.origin.y
        
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: { [weak self] in
            guard let self = self else { return }
            self.updateVisualView(deltaY)
            self.bottomVisualView.constant -= deltaY
            self.view.layoutIfNeeded()
        }) { (_) in }
    }
    
    private func cleanupLocalVariables() {
        vm.mySnapshot = nil
        vm.theirSnapshot = nil
        vm.winner.removeAll()
        vm.results.businesses.removeAll()
        vm.results.selectedBusiness.removeAll()
        vm.results.businessesToSave.removeAll()
        vm.results.theirBusinesses.removeAll()
        restaurantVoteVM.selectedList.removeAll()
        restaurantVoteVM.restaurantList.removeAll()
        vm.friendsRestaurants.removeAll()
        yourWinner.removeAll()
        myHatButtonStatus = .open
        vm.shouldReset = false
        vm.isRandom = false
    }
    
    private func updateVisualView(_ deltaY: CGFloat) {
        if deltaY < -100 {
            let size = CGSize(width: textView.frame.width, height: .infinity)
            let height = textView.sizeThatFits(size)
            heightVisualView.constant = CGFloat(height.height) + 20
        } else if deltaY > 100 {
            heightVisualView.constant += 30
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification?) {
        if (heightKeyboard != 0) { return }
        keyboardWillShow = true
        if let info = notification?.userInfo {
            if let keyboard = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                if (self.keyboardWillShow) {
                    self.heightKeyboard = keyboard.size.height
                    bottomVisualView.constant = heightKeyboard
                    tableView.contentInset.top = -view.safeAreaInsets.bottom + 10
                    let size = CGSize(width: textView.frame.width, height: .infinity)
                    let height = textView.sizeThatFits(size)
                    heightVisualView.constant = CGFloat(height.height) + 20
                    UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
                        self.view.layoutIfNeeded()
                    }) { (isSuccess) in
                        
                    }
                }
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification?) {
        heightKeyboard = 0
        self.keyboardWillShow = false
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseIn, animations: {
            self.bottomVisualView.constant = self.heightKeyboard
            self.tableView.contentInset.top = 10
            self.view.layoutIfNeeded()
        }, completion: nil)
        let height = heightOfBottomView + 5
        heightVisualView.constant = height
        textView.isEditable = true
    }
    
    @objc private func updateBottomView() {
        var height = (tabBarController?.tabBar.frame.height) ?? 42
        if UIDevice.current.orientation.isLandscape {
            height += 20
            heightOfBottomView = height
            tableView.contentInset.top = 25
        } else {
            height += 5
            heightOfBottomView = height
            heightVisualView.constant = height
            tableView.contentInset.top = 5
        }
    }
    
}

// MARK: - TableView Data source and Delegate -
extension ChatingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.countOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = vm.messageViewModel[indexPath.row]
        if message.to == uid {
            let fromCell = tableView.dequeueReusableCell(withIdentifier: "FromCell", for: indexPath) as! FromCell
            fromCell.msgVM = message
            return fromCell
        } else {

            let toCell = tableView.dequeueReusableCell(withIdentifier: "ToCell", for: indexPath) as! ToCell
            toCell.msgVM = message
            toCell.userImage.image = vm.friend_image
            
            return toCell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == vm.countOfCells - 2  {
            vm.fetchMoreMessages(uid: uid)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        vm.pressedCell(at: indexPath)
    }
    
    // MARK: - Navigation -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatingToAbout" {
            let vc = segue.destination as! AboutTableViewController
            vc.name = vm.friend?.name
            vc.uid = vm.friend?.uid
        } else if segue.identifier == "toSearchSettingsVC" {
            let navVC = segue.destination as! UINavigationController
            navVC.navigationBar.barTintColor = .white
            let vc = navVC.topViewController as! RestaurantSettingsTableViewController
            vc.overrideUserInterfaceStyle = .light
            vc.isRandom = vm.isRandom
            vc.delegate = self
            vc.uid = vm.friend?.uid
        } else if segue.identifier == "toVoteController" {
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.topViewController as! VoteTableViewController
            vc.winnerDelegate = self
            vc.friendID = uid
        }
    }
}

// MARK:- TextView Delegate
extension ChatingViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text.starts(with: " ") {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
        textView.isScrollEnabled = false
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let height = textView.sizeThatFits(size)
        heightVisualView.constant = CGFloat(height.height) + 20
        heightConstraintOfStack.constant = CGFloat(height.height)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        vm.startTyping(friendID: uid)

        textView.text = ""
        textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        vm.endTyping(friendID: uid)

        textView.text = ""
        textView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        textView.sizeToFit()
        heightVisualView.constant = heightOfBottomView + 5
        heightConstraintOfStack.constant = 33
        self.view.layoutIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendPressed(sendButton)
            return false
        }
        return true
    }
    
}

extension ChatingViewController: RefreshHatProtocol {
    func refreshHat() {
        if myHatButtonStatus == .poll {
            myHatButtonStatus = .vote
            hatButton.setImage(setImage(.vote), for: .normal)
            enableHatButton()
        } else if myHatButtonStatus == .rando {
            myHatButtonStatus = .winner
            hatButton.setImage(setImage(.winner), for: .normal)
            enableHatButton()
        }
    }
}

extension ChatingViewController: DeclareAWinnerProtocol {
    func declareAWinner() {
        myHatButtonStatus = .winner
        vm.startChoosing(friendID: uid, status: .winner)
        hatButton.setImage(setImage(.winner), for: .normal)
        self.vm.getMyPoints(friendID: self.uid)
        enableHatButton()
    }
}
