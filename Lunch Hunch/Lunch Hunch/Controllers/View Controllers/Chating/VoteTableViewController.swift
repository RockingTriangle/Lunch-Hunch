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
        loadViewIfNeeded()
        tableView.isEditing = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        viewModel.selectedList = []
        viewModel.restaurantList = []
                
        refRestaurants.observe(DataEventType.value, with: {(snapshot) in //JWR
            if snapshot.childrenCount > 0 {
                let data = try? JSONSerialization.data(withJSONObject: snapshot.value!)
                var string = String(data: data!, encoding: .utf8)
                let removeCharacters: Set<Character> = ["\"", "[", "]"]
                string!.removeAll(where: { removeCharacters.contains($0) } )
                let items = string?.components(separatedBy: ",")
                for item in items! {
                    let restaurant = Restaurant(name: item)
                    self.viewModel.restaurantList.append(restaurant)
                }
            }
            
            self.viewModel.restaurantList.sort(by: { $0.name < $1.name })
            for index in (0..<self.viewModel.restaurantList.count - 1) {
                if index == self.viewModel.restaurantList.count {
                    break
                }
                if self.viewModel.restaurantList[index].name == self.viewModel.restaurantList[index + 1].name {
                    self.viewModel.restaurantList.remove(at: index)
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    //MARK: - Properties
    var viewModel = RestaurantController.shared
    var refRestaurants = Database.database().reference().child("messages").child(currentUser.id!).child("picked_restaurants_from_search") //JWR
    var restaurant: Restaurant?
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
        
        calculateWinner()
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
    
    func calculateWinner() {
        
        var points = 1
        while points < 4 {
            RestaurantController.shared.selectedList[points].voteCount += points
            points += 1
        }
    }
    
}//End of class

extension VoteTableViewController: RestaurantListCellDelegate {
    func addedToPickedTapped(isPicked: Bool, restaurant: Restaurant, cell: RestaurantListTableViewCell) {
        RestaurantController.shared.updateIsPicked(isPicked: isPicked, restaurant: restaurant)
        tableView.reloadData()
    }
}//End of extension

