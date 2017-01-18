//
//  LandingViewController.swift
//  PhotoViewer
//
//  Created by ASIM27 on 11/16/16.
//  Copyright © 2016 km3h. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    public var albumsPhotosSplitVC : AlbumsPhotosSplitVC?
    var dataSource : DataSource = DataSource()
    var typePickerView: UIPickerView = UIPickerView()
    var textFieldSessionType : UITextField?
    
    override func loadView()
    {
        self.view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("Photo Viewer", comment: "")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textAlignment = .center
        self.view.addSubview(titleLabel)
        
        let button = UIButton.init()
        button.setTitle(NSLocalizedString("Display Photos", comment: ""), for: .normal)
        button.addTarget(nil, action: #selector(displayPhotosButtonTapped(sender:)), for: .touchUpInside)
        button.setTitleColor(UIColor.brown, for: .normal)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        
        titleLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:-20.0).isActive = true
        
        self.textFieldSessionType = UITextField()
        self.textFieldSessionType?.borderStyle = .line
        self.textFieldSessionType?.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldSessionType?.text = ""
        self.textFieldSessionType?.inputView = self.typePickerView
        self.textFieldSessionType?.delegate = self
        self.view.addSubview(self.textFieldSessionType!)
        
        self.textFieldSessionType?.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        self.textFieldSessionType?.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor).isActive = true
        
        button.topAnchor.constraint(equalTo: (self.textFieldSessionType?.bottomAnchor)!, constant: 20).isActive = true
        button.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor).isActive = true
        
        dataSource.urlString = "http://jsonplaceholder.typicode.com/photos"
        dataSource.urlSessionType = .Delegate
        self.displaySelectedSessionType(sessionType: dataSource.urlSessionType)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(displaySessionTypePicker(sender:)))
        tapRecognizer.numberOfTapsRequired = 1;
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
    }
    
    func displayPhotosButtonTapped(sender: Any)
    {
        if let controller = self.albumsPhotosSplitVC
        {
            controller.dataSource = self.dataSource
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func displaySelectedSessionType(sessionType: URLSessionType?)
    {
        switch sessionType
        {
        case .some(.Delegate):
            self.textFieldSessionType?.text = "Session Type: Delegate"
        case .some(.CompletionHandler):
            self.textFieldSessionType?.text = "Session Type: Completion Handler"
        default:
            break
        }
    }
    
    // MARK: - Delegate methods
    func displaySessionTypePicker(sender: Any)
    {
        self.textFieldSessionType?.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return row == 0 ? "Delegate" : "Completion Handler"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let selectedSessionType = row == 0 ? URLSessionType.Delegate : URLSessionType.CompletionHandler
        dataSource.urlSessionType = selectedSessionType
        self.displaySelectedSessionType(sessionType: selectedSessionType)
    }    
}
