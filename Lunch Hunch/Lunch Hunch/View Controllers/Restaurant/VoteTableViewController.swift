//
//  VoteTableViewController.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import UIKit
import Firebase

protocol DeclareAWinnerProtocol: AnyObject {
    func declareAWinner()
}

class VoteTableViewController: UITableViewController {
    
    // MARK: - Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .light
        loadViewIfNeeded()
        tableView.isEditing = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let allRestaurants = searchModel.businessesToSave + searchModel.theirBusinesses
        voteModel.createRestaurants(with: allRestaurants)
        
        saveButton.isEnabled = false
    }
    
    //MARK: - Properties
    var searchModel = RestaurantSearchModel.shared
    var voteModel = RestaurantVoteModel.shared
    var friendID: String?
    weak var winnerDelegate: DeclareAWinnerProtocol?
    
    //MARK: - ACTIONS
    @IBAction func saveButtonTapped(_ sender: Any) {
        calculatePoints()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return voteModel.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voteModel.sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as? RestaurantVoteListTableViewCell else {return UITableViewCell()}
        
        let restaurant = voteModel.sections[indexPath.section][indexPath.row]
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
            return "Your choices in order (top to bottom)"
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
        voteModel.selectedList.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }

    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func calculatePoints() {
        guard let friendID = friendID else { return }
        let total = RestaurantVoteModel.shared.selectedList.count == 2 ? 3 : 2
        var points = 5
        var index = 0
        while points > total {
            voteModel.selectedList[index].voteCount += points
            index += 1
            points -= 1
        }
        searchModel.savePoints(friendID: friendID, restaurants: voteModel.selectedList)
        winnerDelegate?.declareAWinner()
        dismiss(animated: true)
    }
    
}//End of class

// MARK: - Extensions
extension VoteTableViewController: RestaurantListCellDelegate {
    func addedToPickedTapped(restaurant: Restaurant, cell: RestaurantVoteListTableViewCell) {
        RestaurantVoteModel.shared.updateIsPicked(isPicked: !cell.wasPicked! ? true : false, restaurant: restaurant)
        if RestaurantVoteModel.shared.selectedList.count == 3 || RestaurantVoteModel.shared.restaurantList.isEmpty {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        tableView.reloadData()
    }
}//End of extension

