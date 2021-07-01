//
//  ChatingViewController.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit

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
    @IBOutlet weak var hatButton: UIButton!
    
    @IBOutlet weak var textView    : UITextView!
    @IBOutlet weak var BottomView  : UIVisualEffectView!
    @IBOutlet weak var parentactionStack: UIStackView!
    
    @IBOutlet weak var heightVisualView: NSLayoutConstraint!
    @IBOutlet weak var bottomVisualView: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintOfStack: NSLayoutConstraint!
    
    // MARK: - Properties
    private let button = UIButton()
    public  var name = String()
    public  var uid  = String()
    
    private let database = FBDatabase.shared
    private var selectedCell = Message()
    private let vm       = ChatingViewModel()
    private var current  = 0.0
    
    private var heightKeyboard: CGFloat = 0
    private var heightOfBottomView: CGFloat = 0
    private var keyboardWillShow = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initUserVM()
        initMessageVM()
        initNotifications()
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
        vm.updateBottomViewClouser = { [weak self] in
            guard let self = self else { return }
            self.vm.isFriendBlocked || self.vm.isYouBlocked ? self.hideBottomView() : self.showBottomView()
        }
        vm.updateUserInfoClouser = { [weak self] in
            guard let self = self else { return }
            self.titleLabel.text  = self.vm.friend?.name
            self.statusLabel.text = self.vm.friend?.status
        }
        vm.updateUserImageoClouser = { [weak self] in
            guard let self = self else { return }
            self.button.setImage(self.vm.friend_image, for: .normal)
        }
        vm.updateFriendStatusClouser = { [weak self] in
            guard let self = self else { return }
            self.statusLabel.text = self.vm.isTyping ? "Typing..." : self.vm.friend?.status
        }
//        vm.updatePollingClouser = { [weak self] in
//            guard let self = self else {return}
//            self.
//        }
        vm.fetchUserInfo(uid: uid)
        vm.detectFrindTyping(friendID: uid)
        vm.detectFriendPolling(friendID: uid) //JWR Polling
    }
    
    func initMessageVM() {
        vm.reloadTableViewClouser = { [weak self] in
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
        textView.text = "Aa"
        textView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
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
    func resizeImage(image: UIImage, newWidth: CGFloat, newHieght: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHieght))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHieght))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!.withRenderingMode(.alwaysOriginal)
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
        let alertController = UIAlertController(title: "Would you like this to be a poll or randomizer?", message: nil, preferredStyle: .alert)
        
        let restaurants: [String] = []
        
        let pollAction = UIAlertAction(title: "Poll", style: .default) { _ in
            self.performSegue(withIdentifier: "toVote", sender: nil)
        } //JSWAN - Need to figure out what to do with the completion handler. Will send some data that will start a poll.
        
        let randomAction = UIAlertAction(title: "Randomize", style: .default) { _ in
            let _ = self.restaurantRandomizer(restaurants: restaurants)
        } //JSWAN - Need to figure out what to do with the completion handler. Will send some data that will start a random selection.
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(pollAction)
        alertController.addAction(randomAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - FUNCTIONS
    func restaurantRandomizer(restaurants: [String]) -> String {
        let restaurant = restaurants.randomElement() ?? nil

        return restaurant ?? ""
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatingToAbout" {
            let vc = segue.destination as! AboutTableViewController
            vc.name = vm.friend?.name
            vc.uid = vm.friend?.uid
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
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        vm.endTyping(friendID: uid)
        textView.text = "Aa"
        textView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        textView.sizeToFit()
        heightVisualView.constant = heightOfBottomView + 5
        heightConstraintOfStack.constant = 33
        self.view.layoutIfNeeded()
    }
    
}
