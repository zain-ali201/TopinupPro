//
//  ChooseProviderTypeVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 28/03/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit

protocol ProviderTypeDelegate {
    func setAllProviderType(allProviderTypes : [JobCategory])
}

struct JobCategory {
    var name = ""
    var id = ""
}

class ChooseProviderTypeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSave: UIButton!
    
    var allChoreCategory: [JobCategory] = []
    var selectedRowArray : [IndexPath] = [IndexPath]()
    var selectedCategory: [JobCategory] = []
    var delegate : ProviderTypeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnSave.layer.cornerRadius = self.btnSave.frame.height/2
        self.tableView.register(UINib(nibName: "ChooseChoreCategory", bundle: nil), forCellReuseIdentifier: "cell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.fetchProviderTypesList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fetchProviderTypesList()
    {
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        Api.userApi.getSkillsList() { (success, message, skills) in
            
            hideProgressHud(viewController: self)
            
            if let skills = skills
            {
                self.allChoreCategory.removeAll()
                var index = 0
                for jsonItem in skills
                {
                    let name = jsonItem["name"].stringValue
                    let id = jsonItem["_id"].stringValue
                    let cat: JobCategory = JobCategory(name: name, id: id)
                    self.allChoreCategory.append(cat)
                    for category in self.selectedCategory {
                        if category.id == id {
                            self.selectedRowArray.append(IndexPath(row: index, section: 0))
                        }
                    }
                    index += 1
                }
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        
        if let delegate = delegate
        {
            self.selectedCategory.removeAll()
            for i in selectedRowArray {
                self.selectedCategory.append(allChoreCategory[i.row])
            }
            
            delegate.setAllProviderType(allProviderTypes : self.selectedCategory)
            self.navigationController?.popViewController(animated: true)
            return;
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allChoreCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! ChooseChoreCategoryTVC
        cell.lblName.text = self.allChoreCategory[indexPath.row].name
        
        cell.selectionStyle = .none
        
        if(selectedRowArray.contains(indexPath)) {
            
            UIView.animate(withDuration: 0.25, animations: {
                cell.viewCheckbox.backgroundColor = UIColor(red: 25/255, green: 196/255, blue: 129/255, alpha: 1)
            })
        } else {
            
            UIView.animate(withDuration: 0.25, animations: {
                cell.viewCheckbox.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = IndexPath(row: indexPath.row, section: indexPath.section)
        let cell = self.tableView.cellForRow(at: selectedCell) as! ChooseChoreCategoryTVC
        
        if(!selectedRowArray.contains(indexPath)) {
            selectedRowArray.append(indexPath)
            
            UIView.animate(withDuration: 0.25, animations: {
                cell.viewCheckbox.backgroundColor = UIColor(red: 25/255, green: 196/255, blue: 129/255, alpha: 1)
            })
        } else {
            
            if let index = selectedRowArray.index(of: indexPath) {
                selectedRowArray.remove(at: index)
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                cell.viewCheckbox.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
