//
//  VoteTableViewController.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import UIKit
import Firebase

class VoteTableViewController: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewIfNeeded()
        tableView.isEditing = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        viewModel.selectedList = []
        viewModel.restaurantList = []
                
        loadRestaurantsFromFB()
        
        saveButton.isEnabled = false
    }
    
    //MARK: - Properties
    var viewModel = RestaurantController.shared
    var refRestaurants = Database.database().reference().child("restaurants")
    var restaurant: Restaurant?
    var selectedList: [Restaurant] = RestaurantController.shared.selectedList
    var userID: String?
    var otherUser: String?
    
    //MARK: - ACTIONS
    @IBAction func saveButtonTapped(_ sender: Any) {
        calculatePoints()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as? RestaurantListTableViewCell else {return UITableViewCell()}
        
        let restaurant = viewModel.sections[indexPath.section][indexPath.row]
        cell.wasPicked = indexPath.section == 0 ? true : false
        cell.configure(restaurant: restaurant)
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let sourceSection = sourceIndexPath.section
        let destSection = proposedDestinationIndexPath.section

        if destSection < sourceSection {
            return IndexPath(row: 0, section: sourceSection)
        } else if destSection > sourceSection {
            return IndexPath(row: self.tableView(tableView, numberOfRowsInSection:sourceSection)-1, section: sourceSection)
        }
        return proposedDestinationIndexPath
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Your votes"
        } else if section == 1 {
            return "List of restaurants"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        RestaurantController.shared.selectedList.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func loadRestaurantsFromFB() {
        guard let userID = userID, let otherUser = otherUser else { return }
        refRestaurants.child(userID).child(otherUser).observe(DataEventType.value, with: {(snapshot) in //JWR
            if snapshot.childrenCount > 0 {
                let data = try? JSONSerialization.data(withJSONObject: snapshot.value!)
                var string = String(data: data!, encoding: .utf8)
                let removeCharacters: Set<Character> = ["\"", "{", "}", ":"]
                string!.removeAll(where: { removeCharacters.contains($0) } )
                let items = string?.components(separatedBy: ",")
                for item in items! {
                    var tempName = item
                    tempName.removeFirst(36)
                    let restaurant = Restaurant(name: tempName)
                    self.viewModel.restaurantList.append(restaurant)
                }
                
                if self.viewModel.restaurantList.count > 0 {
                    self.viewModel.restaurantList.sort(by: { $0.name < $1.name })
                    for index in (0..<self.viewModel.restaurantList.count - 1) {
                        if index == self.viewModel.restaurantList.count {
                            break
                        }
                        if self.viewModel.restaurantList[index].name == self.viewModel.restaurantList[index + 1].name {
                            self.viewModel.restaurantList.remove(at: index)
                        }
                    }
                }
                
                self.tableView.reloadData()
            } else {
                self.refRestaurants.child(otherUser).child(userID).observe(DataEventType.value, with: {(snapshot) in //JWR
                    if snapshot.childrenCount > 0 {
                        let data = try? JSONSerialization.data(withJSONObject: snapshot.value!)
                        var string = String(data: data!, encoding: .utf8)
                        let removeCharacters: Set<Character> = ["\"", "{", "}", ":"]
                        string!.removeAll(where: { removeCharacters.contains($0) } )
                        let items = string?.components(separatedBy: ",")
                        for item in items! {
                            var tempName = item
                            tempName.removeFirst(36)
                            let restaurant = Restaurant(name: tempName)
                            self.viewModel.restaurantList.append(restaurant)
                        }
                    }
                    
                    if self.viewModel.restaurantList.count > 0 {
                        self.viewModel.restaurantList.sort(by: { $0.name < $1.name })
                        for index in (0..<self.viewModel.restaurantList.count - 1) {
                            if index == self.viewModel.restaurantList.count {
                                break
                            }
                            if self.viewModel.restaurantList[index].name == self.viewModel.restaurantList[index + 1].name {
                                self.viewModel.restaurantList.remove(at: index)
                            }
                        }
                    }
                    
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func calculatePoints() {
        var points = 5
        var index = 0
        while points > 2 {
            selectedList[index].voteCount += points
            index += 1
            points -= 1
        }
        Database.database().reference().child("points").child(userID!).child(otherUser!).setValue([selectedList[0].name : selectedList[0].voteCount,
                                                                                                   selectedList[1].name : selectedList[1].voteCount,
                                                                                                   selectedList[2].name : selectedList[2].voteCount])
        dismiss(animated: true)
    }
    
}//End of class

// MARK: - Extensions
extension VoteTableViewController: RestaurantListCellDelegate {
    func addedToPickedTapped(restaurant: Restaurant, cell: RestaurantListTableViewCell) {
        RestaurantController.shared.updateIsPicked(isPicked: !cell.wasPicked! ? true : false, restaurant: restaurant)
        if selectedList.count == 3 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        tableView.reloadData()
    }
}//End of extension

