//
//  VoteTableViewController.swift
//  Lunch Hunch
//
//  Created by Jacob Schvaneveldt on 6/24/21.
//

import UIKit
import Firebase

class VoteTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isEditing = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        FirebaseApp.configure() //JWR
        refRestaurants.observe(DataEventType.value, with: {(snapshot) in //JWR
            if snapshot.childrenCount > 0 {
                self.restaurantLists
            }
        })
    }
    
    //MARK: - Properties
    var listOfRestaurants = [String]()

    var refRestaurants = Database.database().reference().child("restaurants").child(currentUser.id!).child("picked_restaurants_from_search") //JWR
    var restaurant: Restaurant?
    var restaurantList: [Restaurant] = RestaurantController.shared.restaurantList
    var selectedList: [Restaurant] = RestaurantController.shared.selectedList
    
    //MARK: - ACTIONS
    @IBAction func addTestButtonTapped(_ sender: Any) {
        let alertController = UIAlertController.init(title: "Add Restaurant", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textfield in
            textfield.placeholder = "Restaurant name.."
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let name = alertController.textFields?.first?.text, !name.isEmpty else {return}
            RestaurantController.shared.createTest(name: name, isPicked: false)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard selectedList.count == 3 else {return}
        
        calculateWinner(restaurants: selectedList)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return RestaurantController.shared.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RestaurantController.shared.sections[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as? RestaurantListTableViewCell else {return UITableViewCell()}
        
        let restaurants = RestaurantController.shared.sections[indexPath.section][indexPath.row]
        
        cell.configure(restaurant: restaurants)
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
        if indexPath.section == 0 {
            return true
        } else if indexPath.section == 1 {
            return true
        } else { return false }
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
    
    func calculateWinner(restaurants: [Restaurant]) {
        
        var points = 3
        
        for restaurant in restaurants {
            restaurant.voteCount += points
            points -= 1
            print(restaurant.voteCount, restaurant.name)
        }
    }
    
}//End of class

extension VoteTableViewController: RestaurantListCellDelegate {
    func addedToPickedTapped(isPicked: Bool, restaurant: Restaurant, cell: RestaurantListTableViewCell) {
        RestaurantController.shared.updateIsPicked(isPicked: isPicked, restaurant: restaurant)
        tableView.reloadData()
    }
}//End of extension

