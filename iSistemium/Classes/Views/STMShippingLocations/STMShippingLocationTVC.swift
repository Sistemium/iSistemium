//
//  STMShippingLocation.swift
//  iSistemium
//
//  Created by Edgar Jan Vuicik on 07/01/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

import Foundation

class STMShippingLocationTVC:STMVariableCellsHeightTVC,UIImagePickerControllerDelegate,UINavigationControllerDelegate,STMPicturesViewerDelegate {
    
    fileprivate var picturesView = UIView()
    
    var THUMB_SIZE:CGSize {
        return CGSize(width: STMSwiftConstants.CELL_IMAGES_SIZE, height: STMSwiftConstants.CELL_IMAGES_SIZE)
    }

    var shippingLocation: STMShippingLocation?{
        didSet{
            if shippingLocation?.location == nil{
                CLGeocoder().geocodeAddressString(shippingLocation?.address ?? "") { (placemarks, error) -> Void in
                    if error == nil{
                        if let firstPlacemark = placemarks?[0] {
                            
                            let location: STMLocation = STMLocationController.locationObject(from: firstPlacemark.location)
                            location.source = "geocoder"
                            self.shippingLocation?.isLocationConfirmed = false
                            self.shippingLocation?.location = location

                            self.tableView.reloadData()

                        }
                    }
                }
            }
            tableView.reloadData()
        }
    }
    
    var spinner : STMSpinnerView?
    
    var cameraOverlayView = UIView()
    
    fileprivate var selectedSourceType : UIImagePickerControllerSourceType?
    
    // Mark: resultsController
    
    fileprivate var _resultsController:NSFetchedResultsController<NSFetchRequestResult>?
    
    override var resultsController: NSFetchedResultsController<NSFetchRequestResult>!{
        get {
            if (_resultsController == nil && shippingLocation != nil) {
                let shippingFetchRequest = STMFetchRequest(entityName: NSStringFromClass(STMShipmentRoutePoint.self))
                shippingFetchRequest.sortDescriptors = [NSSortDescriptor(key: "deviceTs", ascending:false)]
                shippingFetchRequest.predicate = NSPredicate(format: "shippingLocation == %@", shippingLocation!)
                _resultsController = NSFetchedResultsController(fetchRequest: shippingFetchRequest, managedObjectContext: self.document.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
                _resultsController!.delegate = self
            }
            
            return _resultsController
        }
        set {
            _resultsController = newValue
        }
    }
    
    
    //MARK: table view data
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return shippingLocation != nil ? 3 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return resultsController?.fetchedObjects?.count ?? 0
        default :
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return NSLocalizedString("SHIPPING LOCATION", comment: "")
        case 2:
            return NSLocalizedString("SHIPMENT ROUTE POINTS", comment: "")
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for:indexPath) as! STMCustom7TVCell
        switch (indexPath as NSIndexPath).section{
        case 0:
            switch (indexPath as NSIndexPath).row{
            case 0:
                cell.titleLabel?.text = shippingLocation?.name
                cell.detailLabel?.text = ""
            case 1:
                cell.titleLabel?.text = shippingLocation?.address
                cell.detailLabel?.text = ""
            default:
                break
            }
        case 1:
            switch (indexPath as NSIndexPath).row{
            case 0:
                    cell.titleLabel!.font = UIFont.boldSystemFont(ofSize: cell.textLabel!.font.pointSize)
                    cell.titleLabel!.text = ""
                    cell.titleLabel!.textColor = UIColor.black
                    cell.titleLabel!.textAlignment = .center
                    
                    cell.detailLabel!.text = "";
                    cell.detailLabel!.textColor = UIColor.black
                    cell.detailLabel!.textAlignment = .center
                    
                    cell.viewWithTag(666)?.removeFromSuperview()
                    
                    if ((shippingLocation?.location) != nil) {
                        
                        cell.titleLabel!.text = NSLocalizedString("SHOW MAP", comment: "");
                        cell.titleLabel.tintColor = UIColor.black
                        
                        if (!(shippingLocation?.isLocationConfirmed ?? 0).boolValue ) {
                            
                            cell.detailLabel!.text = NSLocalizedString("LOCATION NEEDS CONFIRMATION", comment: "");
                            cell.detailLabel!.textColor = UIColor.red
                            
                        }
                    }else{
                        cell.titleLabel!.text = NSLocalizedString("UNKNOWN LOCATION", comment: "");
                        cell.titleLabel.tintColor = UIColor.gray
                    }
                
                    cell.accessoryType = .none
                
            case 1:
                cell.titleLabel!.text = ""
                cell.detailLabel!.text = ""
                self.picturesView.removeFromSuperview()
                
                self.picturesView = UIView()
                
                if (shippingLocation!.shippingLocationPictures!.count == 0) {
                    
                    let blankPicture = self.blankPicture
                    
                    blankPicture.frame = CGRect(x: 0, y: 0, width: STMSwiftConstants.CELL_IMAGES_SIZE, height: STMSwiftConstants.CELL_IMAGES_SIZE);
                    
                    picturesView.addSubview(blankPicture)
                    
                } else {
                    
                    let showCount = (shippingLocation!.shippingLocationPictures!.count > STMSwiftConstants.LIMIT_COUNT) ? STMSwiftConstants.LIMIT_COUNT : shippingLocation!.shippingLocationPictures!.count;
                    
                    let sortDesriptor = NSSortDescriptor(key: "deviceTs", ascending: false, selector: #selector(NSNumber.compare(_:)))
                    let range = NSMakeRange(0, showCount)
                    
                    let photoArray = (shippingLocation!.shippingLocationPictures! as NSSet).sortedArray(using: [sortDesriptor] )[range.toRange()!]
                    
                    for picture in photoArray {
                        if let pictureData = (picture as! STMPicture).imageThumbnail{
                            let pictureButton = self.pictureButtonWithPicture(pictureData)
                            
                            let count = CGFloat(self.picturesView.subviews.count);
                            let x = (count > 0) ? count * (STMSwiftConstants.CELL_IMAGES_SIZE + STMSwiftConstants.IMAGE_PADDING) : 0;
                            
                            pictureButton.frame = CGRect(x: x, y: 0, width: STMSwiftConstants.CELL_IMAGES_SIZE, height: STMSwiftConstants.CELL_IMAGES_SIZE);
                            
                            self.picturesView.addSubview(pictureButton)
                        }else{
                            let downloadPlaceholder = self.downloadPlaceholder
                            let count = CGFloat(self.picturesView.subviews.count);
                            let x = (count > 0) ? count * (STMSwiftConstants.CELL_IMAGES_SIZE + STMSwiftConstants.IMAGE_PADDING) : 0;
                            downloadPlaceholder.frame = CGRect(x: x, y: 0, width: STMSwiftConstants.CELL_IMAGES_SIZE - 5 , height: STMSwiftConstants.CELL_IMAGES_SIZE - 5);
                            
                            picturesView.addSubview(downloadPlaceholder)
                        }
                    }
                    
                }
                
                
                let addButton = self.addPhotoButton
                
                var x = CGFloat(self.picturesView.subviews.count) * (STMSwiftConstants.CELL_IMAGES_SIZE + STMSwiftConstants.IMAGE_PADDING);
                
                addButton.frame = CGRect(x: x, y: 0, width: STMSwiftConstants.CELL_IMAGES_SIZE, height: STMSwiftConstants.CELL_IMAGES_SIZE);
                
                self.picturesView.addSubview(addButton)
                
                let picturesWidth = STMSwiftConstants.CELL_IMAGES_SIZE * CGFloat(self.picturesView.subviews.count) + STMSwiftConstants.IMAGE_PADDING * CGFloat(self.picturesView.subviews.count - 1)
                x = ceil((cell.contentView.frame.size.width - picturesWidth) / 2);
                let y = ceil((cell.contentView.frame.size.height - STMSwiftConstants.CELL_IMAGES_SIZE) / 2);
                
                self.picturesView.frame = CGRect(x: x, y: y, width: picturesWidth, height: STMSwiftConstants.CELL_IMAGES_SIZE);
                
                cell.contentView.addSubview(self.picturesView)
                
                cell.accessoryType = .none
            default:
                break
            }
        case 2:
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            cell.titleLabel?.text = formatter.string(from: (resultsController!.fetchedObjects![(indexPath as NSIndexPath).row] as! STMShipmentRoutePoint).shipmentRoute!.date!)
            cell.detailLabel?.text = (resultsController!.fetchedObjects![(indexPath as NSIndexPath).row] as! STMShipmentRoutePoint).shortInfo()
        default:
            break
        }
        cell.selectionStyle = .none
        cell.layoutIfNeeded()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch ((indexPath as NSIndexPath).section){
            
        case 1:
            switch ((indexPath as NSIndexPath).row) {
            case 1:
                return STMSwiftConstants.CELL_IMAGES_SIZE + STMSwiftConstants.IMAGE_PADDING * 2;
            default:
                break;
            }
            
        default:
            break;
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).section == 1) {
            
            switch ((indexPath as NSIndexPath).row) {
            case 0:
                if ((shippingLocation?.location) != nil) {
                    performSegue(withIdentifier: "showShippingLocationMap", sender:self.shippingLocation)
                }
            default:
                break;
            }
            
        }
    }
    
    // MARK: photos
    
    fileprivate var blankPicture:UIView {
    
    let image = STMFunctions.resize(UIImage(named:"Picture-100")!, to:THUMB_SIZE).withRenderingMode(.alwaysTemplate)
    let imageView = UIImageView(image: image)
    imageView.tintColor = UIColor.lightGray
    
    return imageView;
    
    }
    
    fileprivate var downloadPlaceholder:UIView {
        
        let image = STMFunctions.resize(UIImage(named:"Download-100")!, to:THUMB_SIZE).withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = UIColor.gray
        let tap = UITapGestureRecognizer(target: self, action: #selector(STMShippingLocationTVC.photoButtonPressed(_:)))
        imageView.gestureRecognizers = [tap]
        imageView.isUserInteractionEnabled = true
        return imageView;
        
    }
    
    fileprivate func pictureButtonWithPicture(_ data : Data) -> UIView{
    
    let imageView = UIImageView(image: UIImage(data: data))
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(STMShippingLocationTVC.photoButtonPressed(_:)))
    imageView.gestureRecognizers = [tap]
    imageView.isUserInteractionEnabled = true
    
    return imageView;
    
    }
    
    fileprivate var addPhotoButton : UIView {
    
    let imageView = UIImageView(image: STMFunctions.resize(UIImage(named: "plus")!, to:THUMB_SIZE))
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(STMShippingLocationTVC.addPhotoButtonPressed(_:)))
    imageView.gestureRecognizers = [tap]
    imageView.isUserInteractionEnabled = true
    
    return imageView;
    
    }
    
    func addPhotoButtonPressed(_ sender:AnyObject) {
    self.showImagePickerForSourceType(.camera)
    
    }
    
    func photoButtonPressed(_ sender:AnyObject) {
    
    if sender.isKind(of: UITapGestureRecognizer.self){
        let tappedView = (sender as! UIGestureRecognizer).view
        performSegue(withIdentifier: "showPhotos",sender:tappedView)
    }
    
    }
    
    func showImagePickerForSourceType( _ imageSourceType:UIImagePickerControllerSourceType ){
    if UIImagePickerController.isSourceTypeAvailable(imageSourceType) {
        self.selectedSourceType = imageSourceType;
        self.present(self.imagePickerController!, animated: true, completion: nil)
        }
    
    }
    
    fileprivate var _imagePickerController:STMImagePickerController?
    
    var imagePickerController:STMImagePickerController? {
        get{
            if _imagePickerController == nil{
                _imagePickerController = STMImagePickerController()
                _imagePickerController!.delegate = self;
                
                _imagePickerController!.sourceType = self.selectedSourceType!;
                
                if _imagePickerController!.sourceType == .camera {
                    
                    _imagePickerController!.showsCameraControls = false
                    
                    Bundle.main.loadNibNamed("STMCameraOverlayView", owner: self, options: nil)
                    
                    _imagePickerController?.setFrameForCameraOverlayView(self.cameraOverlayView)
                    
                    _imagePickerController!.cameraOverlayView = self.cameraOverlayView;
                    
                }
            }
            
            return _imagePickerController
    
        }
        set{
            _imagePickerController = nil
        }
    }
    
    
    func saveImage(_ image:UIImage) {
    
        let shippingLocationPicture = STMObjectsController.newObject(forEntityName: NSStringFromClass(STMShippingLocationPicture.self), isFantom:false) as! STMShippingLocationPicture
        
        let jpgQuality = STMPicturesController.jpgQuality()
        
        STMPicturesController.setImagesFrom(UIImageJPEGRepresentation(image, jpgQuality),for: shippingLocationPicture ,andUpload:true)

        shippingLocationPicture.shippingLocation = self.shippingLocation
        self.document.save{
            if ($0) {
                self.spinner?.removeFromSuperview()
                self.tableView.reloadData()
            }
        }
    
    }
    
    func photoWasDeleted(_ photo:STMPhoto) {
        tableView.reloadData()
    }
    
    // MARK: Camera buttons
    
    
    @IBAction func cameraButtonPressed(_ sender:AnyObject) {
        
    self.spinner = STMSpinnerView(frame: self.view.bounds, indicatorStyle: .whiteLarge, backgroundColor:UIColor.gray, alfa:0.75)
    self.view.addSubview(self.spinner!)
    self.imagePickerController!.cameraOverlayView!.addSubview(STMSpinnerView(frame: self.imagePickerController!.cameraOverlayView!.bounds, indicatorStyle: .whiteLarge, backgroundColor:UIColor.gray, alfa:0.75))
    self.imagePickerController!.takePicture()
    }
    
    @IBAction func cancelButtonPressed(_ sender:AnyObject) {
    self.imagePickerControllerDidCancel(self.imagePickerController!)
    }
    
    @IBAction func photoLibraryButtonPressed(_ sender:AnyObject) {
    self.cancelButtonPressed(sender)
    self.showImagePickerForSourceType(.photoLibrary)
    }
    
    // MARK:  Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            let picturesPVC = segue.destination as! STMShippingLocationPicturesPVC
            
            let sortDesriptor = NSSortDescriptor(key: "deviceTs", ascending: false, selector: #selector(NSNumber.compare(_:)))
            let photoArray = (shippingLocation!.shippingLocationPictures! as NSSet).sortedArray(using: [sortDesriptor])
            
            picturesPVC.photoArray =  NSMutableArray(array: photoArray)
            let index = picturesView.subviews.index(of: sender as! UIView)
            picturesPVC.currentIndex = UInt(index ?? 0)
            picturesPVC.parentVC = self
        }
        if segue.identifier == "showShippingLocationMap" {
            
            let mapVC = segue.destination as! STMShippingLocationMapVC
            
            mapVC.shippingLocation = self.shippingLocation
            
        }
    }

    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: false){
            self.saveImage(info[UIImagePickerControllerOriginalImage] as! UIImage)
            self.imagePickerController = nil
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false,completion: nil)
            imagePickerController = nil
    }
    
    // MARK: view lifecycle
    
    override func customInit() {
        super.customInit()
        self.cellIdentifier = "shippingLocationCell"
        let cellNib = UINib(nibName: NSStringFromClass(STMCustom7TVCell.self), bundle:nil)
        self.tableView.register(cellNib, forCellReuseIdentifier:self.cellIdentifier)
        performFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}
