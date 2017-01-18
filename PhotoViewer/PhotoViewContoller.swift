//
//  PhotoViewContoller.swift
//  PhotoViewer
//
//  Created by ASIM27 on 11/17/16.
//  Copyright © 2016 km3h. All rights reserved.
//

import UIKit

class PhotoViewContoller: UIViewController
{
    public var dataSource : DataSource?
    public var photo : [String:AnyObject]?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.dataSource?.photo(photoType: .FULLPHOTO, photo: self.photo) { image in
            self.imageView.image = image
        }
    }
}
