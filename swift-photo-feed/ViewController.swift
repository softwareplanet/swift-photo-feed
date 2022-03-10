//
//  ViewController.swift
//  swift-photo-feed
//
//  Created by Viktoriia Vovk on 09.03.2022.
//

import UIKit
import PhotosUI
import Photos

class SelectPhotoCell: UICollectionViewCell {
  @IBOutlet weak var galleryImage: UIImageView!
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
  @IBOutlet var collectionView: UICollectionView! {
    didSet {
      collectionView.isHidden = true
    }
  }
  
  var allPhotos : PHFetchResult<PHAsset>? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    PHPhotoLibrary.requestAuthorization { (status) in
      switch status {
      case .authorized, .limited:
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if self.allPhotos != nil {
          
          DispatchQueue.main.async {
            self.collectionView?.isHidden = false
            self.collectionView?.reloadData()
          }
        }
      case .denied, .restricted, .notDetermined:
        break
      @unknown default:
        break
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! SelectPhotoCell
    
    if self.allPhotos != nil {
      let asset = self.allPhotos?.object(at: indexPath.row)
      
      cell.galleryImage?.fetchImage(asset: asset!, contentMode: .aspectFit, targetSize: cell.galleryImage.frame.size)
    }
    
    return cell
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.allPhotos?.count ?? 0
  }
}


extension UIImageView{
  func fetchImage(asset: PHAsset, contentMode: PHImageContentMode, targetSize: CGSize) {
    let options = PHImageRequestOptions()
    options.version = .original
    PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { image, _ in
      guard let image = image else { return }
      switch contentMode {
      case .aspectFill:
        self.contentMode = .scaleAspectFill
      case .aspectFit:
        self.contentMode = .scaleAspectFit
      @unknown default: break
      }
      self.image = image
    }
  }
}
