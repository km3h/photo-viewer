//
//  PhotosViewController.swift
//  PhotoViewer
//
//  Created by ASIM27 on 11/16/16.
//  Copyright © 2016 km3h. All rights reserved.
//

import UIKit

struct PhotosViewControllerConstants
{
    static let approximateCellWidth : CGFloat = 100.0
    static let cellMargin : CGFloat = 3.0
}

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    public var photos : [[String:AnyObject]]?
    public var dataSource : DataSource?
    public var albumId : NSNumber?
    
    var collectionView : UICollectionView?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // collection view layout
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.itemSize = CGSize(width: 100, height: 100)
        collectionViewLayout.minimumInteritemSpacing = PhotosViewControllerConstants.cellMargin
        collectionViewLayout.minimumLineSpacing = PhotosViewControllerConstants.cellMargin
        
        //setup collection view
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView?.backgroundColor = UIColor(colorLiteralRed: 0.91, green: 0.91, blue: 0.91, alpha: 1)
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        
        //add collection view
        self.view.addSubview(collectionView!)
        collectionView!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        collectionView!.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        collectionView!.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        collectionView!.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.reloadData()
        self.setLayout(size: self.view.bounds.size)
        if let albumId = self.albumId
        {
            self.title = "Album \(albumId)"
        }
        else
        {
            self.title = "Select Album"
        }
        super.viewWillAppear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        self.setLayout(size: size)
    }
    
    func setLayout(size : CGSize)
    {
        //thumbnails are about 100 x 100 points in size
        let approximateNumberOfViewsInWidth = size.width / PhotosViewControllerConstants.approximateCellWidth
        let numberOfViewInWidth = ceil(approximateNumberOfViewsInWidth)
        let cellWidth = size.width / numberOfViewInWidth - PhotosViewControllerConstants.cellMargin
        let collectionLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        collectionLayout?.itemSize = CGSize(width: cellWidth, height: cellWidth)
        collectionLayout?.invalidateLayout()
    }
    
    public func reloadData()
    {
        self.dataSource?.photoDictionary() { json in
            DispatchQueue.main.async() {
                self.photos = json?[self.albumId!]
                self.collectionView?.reloadData()
            }
        }
    }
    
    // MARK: - Collection view
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if let photos = self.photos
        {
            return photos.count
        }
        else
        {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let imageView = UIImageView();
        imageView.translatesAutoresizingMaskIntoConstraints = false
        collectionCell.contentView.addSubview(imageView);
        
        imageView.leadingAnchor.constraint(equalTo: collectionCell.contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: collectionCell.contentView.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: collectionCell.contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: collectionCell.contentView.bottomAnchor).isActive = true
        
        self.dataSource?.photo(photoType: .THUMBNAIL, photo: self.photos?[indexPath.row]) { image in
            imageView.image = image
        }
        
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let storyboard = UIStoryboard(name: "PhotoViewController", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! PhotoViewController
        controller.photo = self.photos?[indexPath.row];
        controller.dataSource = self.dataSource
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(photoViewControllerCancelTapped))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(photoViewControllerSaveTapped))
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .formSheet
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - photo modal actions
    
    func photoViewControllerCancelTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func photoViewControllerSaveTapped()
    {
        let row = self.collectionView?.indexPathsForSelectedItems?.first?.row
        
        self.dataSource?.photo(photoType: .FULLPHOTO, photo: self.photos?[row!]) { image in
            if let _image = image
            {
                UIImageWriteToSavedPhotosAlbum(_image, self, #selector(self.imageSaveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    func imageSaveCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let error = error
        {
            let ac = UIAlertController(title: "Save Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.presentedViewController?.present(ac, animated: true)
        }
        else
        {
            let ac = UIAlertController(title: "Saved", message: "The image was saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.presentedViewController?.present(ac, animated: true)
        }
    }
}

