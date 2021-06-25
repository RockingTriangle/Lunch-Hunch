//
//  FoodTypesViewController.swift
//  Lunch Hunch
//
//  Created by Mike Conner on 6/24/21.
//

import UIKit

class FoodTypesViewController: UIViewController {
    
    @IBOutlet weak var allToggle: UISwitch!
    @IBOutlet weak var italianToggle: UISwitch!
    @IBOutlet weak var mexicantoggle: UISwitch!
    @IBOutlet weak var americanToggle: UISwitch!
    @IBOutlet weak var asianToggle: UISwitch!
    @IBOutlet weak var indianToggle: UISwitch!
    @IBOutlet weak var hawaiianToggle: UISwitch!
    @IBOutlet weak var mediterraneanToggle: UISwitch!
    @IBOutlet weak var burgersToggle: UISwitch!
    @IBOutlet weak var bbqToggle: UISwitch!
    @IBOutlet weak var tacosToggle: UISwitch!
    @IBOutlet weak var pizzaToggle: UISwitch!
    @IBOutlet weak var sushiToggle: UISwitch!
    @IBOutlet weak var buffetsToggle: UISwitch!
    @IBOutlet weak var sandwichToggle: UISwitch!
    @IBOutlet weak var steakhouseToggle: UISwitch!
    @IBOutlet weak var glutenFreeToggle: UISwitch!
    @IBOutlet weak var veganToggle: UISwitch!
    @IBOutlet weak var saladToggle: UISwitch!
    @IBOutlet weak var seafoodToggle: UISwitch!
    
    var viewModel = RestaurantViewModel.shared
    var toggleArray: [UISwitch] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        toggleArray = [allToggle, italianToggle, mexicantoggle, americanToggle,
                       asianToggle, indianToggle, hawaiianToggle, mediterraneanToggle,
                       burgersToggle, bbqToggle, tacosToggle, pizzaToggle,
                       sushiToggle, buffetsToggle, sandwichToggle, steakhouseToggle,
                       glutenFreeToggle, veganToggle, saladToggle, seafoodToggle]
        configureViews()
    }
    
    @IBAction func toggleWasTapped(_ sender: UISwitch) {
        
        let index = sender.tag
        
        switch index {
        case 0:
            for toggle in (0...19) {
                toggleArray[toggle].isOn = false
                viewModel.foodTypes[toggle] = false
            }
            toggleArray[0].isOn.toggle()
            viewModel.foodTypes[0] = toggleArray[0].isOn
        default:
            toggleArray[0].isOn = false
            viewModel.foodTypes[0] = toggleArray[0].isOn
            viewModel.foodTypes[index] = toggleArray[index].isOn
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func configureViews() {
        for index in (0...19) {
            if viewModel.foodTypes[index] {
                toggleArray[index].isOn = true
            } else {
                toggleArray[index].isOn = false
            }
        }
    }
}
