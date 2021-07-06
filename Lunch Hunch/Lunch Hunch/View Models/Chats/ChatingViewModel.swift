//
//  ChatingViewModel.swift
//  Lunch Hunch
//
//  Created by Lunch Hunch Team on 6/14/21.
//

import UIKit
import Firebase

class ChatingViewModel {
    
    // MARK: - Properties
    public  var friend             : UserViewModel? { didSet { updateUserInfoClosure?() }}
    public  var friend_image       : UIImage? { didSet { updateUserImageoClosure?() }}
    public  var messageViewModel   = [MessageViewModel]() { didSet { reloadTableViewClosure?() }}
    public  var countOfCells       : Int { return messageViewModel.count }
    
    private var queryStart         : Double?
    private var unreadMessages     = [String]()
    public  var selectedCell       : MessageViewModel?
    public  var friendsHatStatus   = HatStatus.open { didSet { updateChoosingClosure?() }}
    public  var friendsRestaurants = [String]()
    public  var friendID           = ""
    public  var mySnapshot         : DataSnapshot?
    public  var theirSnapshot      : DataSnapshot?
    public  var winner             = ""
    public  var isRandom           = false
    public  var shouldReset        = false { didSet { updateResetClosure?() }}
    
    private var lastIsReached   = false
    private var isFetching      = false
    public  var isNew           = false
    public  var isTyping        = false { didSet { updateFriendStatusClosure?() }}
    public  var isFriendBlocked = false { didSet { updateBottomViewClosure?() }}
    public  var isYouBlocked    = false { didSet { updateBottomViewClosure?() }}
    public  var isChoosing      = false { didSet { updateChoosingClosure?() }}
    
    var updateUserInfoClosure      : (()->())?
    var updateUserImageoClosure    : (()->())?
    var reloadTableViewClosure     : (()->())?
    var updateTableViewClosure     : (()->())?
    var updateFriendStatusClosure  : (()->())?
    var updateBottomViewClosure    : (()->())?
    var updateChoosingClosure      : (()->())?
    var updateResetClosure         : (()->())?
    
    var results = RestaurantSearchModel.shared
    
    // MARK:- Fetch friend info
    public func fetchUserInfo(uid: String) {
        FBDatabase.shared.readMessages(id: uid)
        FBDatabase.shared.loadChatingUser(for: uid) { [weak self] (user, error) in
            guard let self = self else { return }
            if error == nil {
                self.friend = self.createUserViewModel(user: user!)
                self.createUserImage(url: (user?.imageURL)!)
            } else { print(error!) }
        }
    }
    
    private func createUserViewModel(user: User) -> UserViewModel {
        let name = user.first! + " " + user.last!
        let lastOnlineDate = user.lastOnlineDate.getDays() == "Just now" ? "Just now": "Active \(user.lastOnlineDate.getDays()) ago"
        let availability = DefaultSettings.shared.availability()
        let status = isYouBlocked || isFriendBlocked || !availability ? "" : user.isOnline! ? "Online" : lastOnlineDate
        return UserViewModel(name: name, username: user.username!, email: user.email!, imageURL: user.imageURL!, uid: user.id!, status: status)
    }
    
    private func createUserImage(url: String) {
        let imageView = UIImageView()
        imageView.KFload(url: url) { [weak self] (image) in
            guard let self = self else { return }
            self.friend_image = image
        }
    }
    
    // MARK:- Fetch Messages
    public func fetchMessages(uid: String) {
        FBDatabase.shared.loadUnreadMessages(id: uid) { [weak self] (keys) in
            guard let self = self else { return }
            if keys!.count > 0 {
                self.unreadMessages.append(contentsOf: keys!)
            } else { self.checkFriendSeenMessage(uid: uid) }
        }
        guard !isFetching else { return }
        isFetching = true
        FBDatabase.shared.loadMessages(for: uid, queryStart: queryStart) { [weak self] (newMessages) in
            guard let self = self else { return }
            self.lastIsReached = newMessages.count == 0
            if self.lastIsReached {
                self.fetchNewMessages(uid: uid, messages: newMessages)
                return
            }
            self.lastIsReached = newMessages.count < 20
            self.queryStart = newMessages[newMessages.count-1].timestamp
            if newMessages.count == 20 {
                var messages = newMessages
                messages.removeLast()
                self.createMessageViewModel(messages: messages)
            } else {
                self.createMessageViewModel(messages: newMessages)
            }
            self.fetchNewMessages(uid: uid, messages: newMessages)
            self.isFetching = false
        }
    }
    
    // Fetch the new messages
    public func fetchNewMessages(uid: String, messages: [Message]) {
        FBDatabase.shared.loadNewMessages(for: uid, lastMessages: messages) { [weak self] (newMessage) in
            guard let self = self else { return }
            self.isFetching = false
            self.isNew = true
            self.createNMessageViewModel(message: newMessage!)
        }
    }
    
    // Fetching more messages (Pagenation)
    public func fetchMoreMessages(uid: String) {
        guard !isFetching else { return }
        guard !lastIsReached else { return }
        isFetching = true
        FBDatabase.shared.loadMessages(for: uid, queryStart: queryStart) { [weak self] (newMessages) in
            guard let self = self else { return }
            let NMsgsCount = newMessages.count
            self.lastIsReached = NMsgsCount == 0
            self.lastIsReached = NMsgsCount < 20
            self.queryStart = newMessages[NMsgsCount-1].timestamp
            if NMsgsCount == 20 {
                var messages = newMessages
                messages.removeLast()
                self.createMessageViewModel(messages: messages)
            } else {
                self.createMessageViewModel(messages: newMessages)
            }
            
            self.isFetching = false
        }
    }
    
    private func createMessageViewModel(messages: [Message]) {
        var vms = [MessageViewModel]()
        for message in messages {
            vms.append(proccessFetchMessage(message: message))
        }
        messageViewModel.append(contentsOf: vms)
    }
    
    private func createNMessageViewModel(message: Message) {
        messageViewModel.insert(proccessFetchMessage(message: message), at: 0)
    }
    
    private func proccessFetchMessage(message: Message) -> MessageViewModel {
        let isSeen = checkSeenMessage(message: message)
        return MessageViewModel(to: message.to, text: message.text, timestamp: message.timestamp, msgKind: message.msgKind, isSeen: isSeen)
    }
    
    func pressedCell(at indexpath: IndexPath) {
        selectedCell = messageViewModel[indexpath.row]
    }
    
    // MARK:- Handle unread messages
    func readMessages(friendID: String) {
        FBDatabase.shared.readMessages(id: friendID)
    }
    
    private func checkFriendSeenMessage(uid: String) {
        var newVM = [MessageViewModel]()
        self.messageViewModel.forEach { (message) in
            var msg = message
            msg.isSeen = true
            newVM.append(msg)
            if msg.timestamp == self.messageViewModel.last?.timestamp {
                self.messageViewModel = newVM
            }
        }
    }
    
    private func checkSeenMessage(message: Message) -> Bool {
        let isSeen = unreadMessages.contains(message.key!) ? false : true
        return isSeen
    }
    
    // MARK:- Handling send message
    func sendTextMessage(uid: String, text: String) {
        FBDatabase.shared.sendMessage(to: uid, msg: text, msgKind: .text, voiceSec: 0)
    }
    
    // MARK:- Handle typing action
    func startTyping(friendID: String) {
        FBDatabase.shared.FBStartTypingUser(friendID: friendID)
    }
    
    func endTyping(friendID: String) {
        FBDatabase.shared.FBEndTypingUser(friendID: friendID)
    }
    
    func detectFriendTyping(friendID: String) {
        FBDatabase.shared.FBDetectFriendTyping(friendID: friendID) { [weak self] (isTyping) in
            guard let self = self else { return }
            self.isTyping = isTyping
        }
    }
    
    //MARK: - Handle Restaurants Actions
    func detectRandomWinner(friendID: String) {
        FBDatabase.shared.FBDetectRandomWinner(friendID: friendID) { [weak self] (winner) in
            guard let self = self else { return }
            if self.winner == "" {
                self.winner = winner ?? ""
            }
        }
    }
    
    func startChoosing(friendID: String, status: HatStatus) {
        FBDatabase.shared.FBStartChoosing(friendID: friendID, status: status)
    }
    
    func stopChoosing(friendID: String) {
        FBDatabase.shared.FBEndChoosing(friendID: friendID)
    }
    
    func detectChoosing(friendID: String) {
        FBDatabase.shared.FBDetectChoosing(friendID: friendID) { [weak self] (status) in
            guard let self = self else { return }
            self.friendsHatStatus = status ?? .open
            if self.friendsHatStatus == .rando {
                self.isRandom = true
            }
        }
    }
    
    func detectRestaurants(friendID: String) {
        FBDatabase.shared.FBDetectRestaurants(friendsID: friendID) { [weak self] (restaurants) in
            guard let self = self else { return }
            guard let restaurants = restaurants else { return }
            self.friendsRestaurants = restaurants
            if self.friendsRestaurants.count > 0 && self.results.businessesToSave.count > 0 {
                if self.isRandom == true {
                    self.startChoosing(friendID: friendID, status: .winner)
                } else {
                    self.startChoosing(friendID: friendID, status: .vote)
                }
            }
        }
    }
    
    func getMyPoints(friendID: String) {
        FBDatabase.shared.FBGetMyPoints(friendID: friendID) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let snapshot = snapshot else { return }
            self.mySnapshot = snapshot
            self.friendID = friendID
        }
    }
    
    func getThierPoints(friendID: String) {
        FBDatabase.shared.FBGetTheirPoints(friendID: friendID) { [weak self] (snapshot) in
            guard let self = self else { return }
            guard let snapshot = snapshot else { return }
            self.theirSnapshot = snapshot
            self.friendID = friendID
            self.friendsHatStatus = .winner
        }
    }
    
    func checkForWinner(friendID: String) {
        if isRandom {
            if winner == "" {
                declareRandomWinner(friendID: friendID)
            }
        } else {
            guard let uid = Auth.auth().currentUser?.uid, let mySnapshot = mySnapshot, let theirSnapshot = theirSnapshot else { return }
            declarePollWinner(id: uid, friendID: friendID, mySnapshot: mySnapshot, theirSnapshot: theirSnapshot)
        }
    }
    
    func declareRandomWinner(friendID: String) {
        let randomChoices = results.businessesToSave + friendsRestaurants
        winner = randomChoices.randomElement() ?? "Failed to select random winner"
        Database.database().reference().child("seen").removeAllObservers()
        FBDatabase.shared.FBSetWinner(friendID: friendID, winner: winner)
    }
    
    func declarePollWinner(id: String, friendID: String, mySnapshot: DataSnapshot, theirSnapshot: DataSnapshot) {
        
        var choices: [String: Int] = [:]
        
        if mySnapshot.childrenCount > 0 {
            let data = try? JSONSerialization.data(withJSONObject: mySnapshot.value!)
            var string = String(data: data!, encoding: .utf8)
            let removeCharacters: Set<Character> = ["{", "}", ":", "\""]
            string!.removeAll(where: { removeCharacters.contains($0) } )
            let items = string?.components(separatedBy: ",")
            for item in items! {
                let points = item.last
                let restaurant = item.dropLast()
                choices[String(restaurant)] = Int(String(points!))
            }
        }
        
        if theirSnapshot.childrenCount > 0 {
            let data = try? JSONSerialization.data(withJSONObject: theirSnapshot.value!)
            var string = String(data: data!, encoding: .utf8)
            let removeCharacters: Set<Character> = ["{", "}", ":", "\""]
            string!.removeAll(where: { removeCharacters.contains($0) } )
            let items = string?.components(separatedBy: ",")
            for item in items! {
                let points = item.last
                let restaurant = item.dropLast()
                if choices[String(restaurant)] != nil {
                    choices[String(restaurant)] = choices[String(restaurant)]! + Int(String(points!))!
                } else {
                    choices[String(restaurant)] = Int(String(points!))
                }
            }
        }
        
        var maxPoints = 0
        var restaurantsTied = [String]()
        var restaurantWinner = ""
        for choice in choices {
            if choice.value > maxPoints {
                restaurantWinner = choice.key
                maxPoints = choice.value
                restaurantsTied.removeAll()
            } else if choice.value == maxPoints {
                restaurantsTied.append(choice.key)
            }
        }
        
        if restaurantsTied.count > 0 {
            winner = "There was a tie, please try again."
        } else {
            winner = "Your winner is \(restaurantWinner) with \(maxPoints) points"
        }
    }
    
    func setSeeWinner(friendID: String) {
        FBDatabase.shared.FBSeenWinner(friendID: friendID)
    }
    
    func detectSeenWinner(friendID: String) {
        FBDatabase.shared.FBDetectSeenWinner(friendID: friendID)  { [weak self] isSeen in
            guard let self = self, let isSeen = isSeen else { return }
            if isSeen == true {
                self.shouldReset = true
                Database.database().reference().child("seen").child(friendID).child(currentUser.id!).removeAllObservers()
            }
        }
    }
    
    func cleanUpFBDatabase(friendID: String) {
        FBDatabase.shared.FBCleanUp(friendID: friendID) 
    }
 
    // MARK:- Check Blocking
    func checkBlocking(uid: String) {
        if FBNetworkRequest.shared.blockedList.isEmpty {
            FBNetworkRequest.shared.fetchBlockedList { [weak self] (_) in
                guard let self = self else { return }
                self.isFriendBlocked = FBNetworkRequest.shared.blockedList.contains(uid)
            }
        } else {
            self.isFriendBlocked = FBNetworkRequest.shared.blockedList.contains(uid)
        }
        
        if FBNetworkRequest.shared.blockedByList.isEmpty {
            FBNetworkRequest.shared.fetchBlockedByList { [unowned self] (_) in
                self.isYouBlocked = FBNetworkRequest.shared.blockedByList.contains(uid)
            }
        } else {
            self.isYouBlocked = FBNetworkRequest.shared.blockedByList.contains(uid)
        }
    }
    
}

// MARK:- Message View Model
struct MessageViewModel {
    
    var to       : String?
    var text     : String?
    var timestamp: Double?
    var msgKind  : String?
    var isSeen   : Bool?
    
}
