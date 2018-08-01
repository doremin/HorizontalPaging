//
//  ViewController.swift
//  Test
//
//  Created by doremin on 29/06/2018.
//  Copyright © 2018 doremin. All rights reserved.
//

import MapKit
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionVIew: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locations = [CLLocation(latitude: 37.5667046, longitude: 126.99572940000007),
                     CLLocation(latitude: 37.5670094, longitude: 126.99703160000001),
                     CLLocation(latitude: 37.5673094, longitude: 126.9983160000001)]
    
    lazy var stations = self.locations.map { location in
        return Station(text: "\(self.locations.index(of: location)! + 1)", coordinate: location.coordinate)
    }
    
    lazy var detailView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor(hexString: "#38acf7")
        
        let directionView = UIView()
        directionView.frame.size = CGSize(width: self.view.frame.width * 0.8, height: 0)
        directionView.center.y = self.view.center.y
        directionView.backgroundColor = UIColor.white
        
        let numberCircleLabel = UILabel()
        numberCircleLabel.frame = CGRect(origin: CGPoint(x: 20, y: 20), size: CGSize(width: 30, height: 30))
        numberCircleLabel.layer.masksToBounds = true
        numberCircleLabel.layer.cornerRadius = 15
        numberCircleLabel.backgroundColor = UIColor.white
        numberCircleLabel.textAlignment = .center
        numberCircleLabel.textColor = UIColor(hexString: "#38acf7")
        
        
        view.addSubview(directionView)
        view.addSubview(numberCircleLabel)
        
        self.mapView.register(StationsMarker.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        return view
    }()
    
    var currentIndex = 0
    var contents = Array(0 ..< 10)
    var isFirstTransform = false
    var isDetailOpened = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        self.mapView.isUserInteractionEnabled = false
        self.mapView.isScrollEnabled = false
        
        let viewTapGeusture = UITapGestureRecognizer(target: self, action: #selector(viewDidTap(sender:)))
        viewTapGeusture.numberOfTapsRequired = 1
        
        self.collectionVIew.delegate = self
        self.collectionVIew.dataSource = self
        
        self.isFirstTransform = true
        
        self.collectionVIew.showsHorizontalScrollIndicator = false
        self.collectionVIew.backgroundColor = UIColor.clear
        
        let layout = self.collectionVIew.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: self.view.center.x - 75, bottom: 0, right: self.view.center.x - 75)
        layout.itemSize = CGSize(width: 150, height: 200)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        
        self.view.addSubview(self.detailView)
        self.view.bringSubview(toFront: self.collectionVIew)
        self.view.bringSubview(toFront: self.detailView)
        
        self.mapView.addGestureRecognizer(viewTapGeusture)
        
        centerMapOnLocation(location: CLLocation(latitude: 37.566386, longitude: 126.99793979999999))
        
        self.mapView.addAnnotations(self.stations)
        mapView.selectAnnotation(stations[currentIndex], animated: true)
    }
    
    // MARK: Background view did tap
    @objc func viewDidTap(sender: UITapGestureRecognizer) {
        self.mapView.isUserInteractionEnabled = false
        
        guard let cell = collectionVIew.cellForItem(at: IndexPath(item: currentIndex, section: 0)) else {
            fatalError("cell nil")
        }
        
        if sender.state == .ended {
            if isDetailOpened {
                UIView.animate(withDuration: 0.6, animations: {
                    self.collectionVIew.frame.origin.y -= 300
                    self.detailView.frame = CGRect(x: self.view.center.x - 75, y: self.view.center.y - 100, width: 150, height: 200)
                    self.detailView.subviews.first?.frame = CGRect(x: (self.detailView.bounds.maxX + self.detailView.bounds.minX) / 2, y: self.detailView.bounds.maxY, width: 0, height: 0)
                    
                }) { _ in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.detailView.frame.origin.x = self.view.center.x - 75
                        self.detailView.frame.origin.y = self.collectionVIew.frame.origin.y + cell.frame.minY
                    }, completion: { _ in
                        self.detailView.isHidden = true
                        cell.isHidden = false
                    })
                }
            }
        }
        
        
        isDetailOpened = false
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        
        self.mapView.setRegion(region, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth: Float = 150 + 10
        
        let currentOffset = Float(scrollView.contentOffset.x)
        var newOffset: CGFloat = 0.0
        
        newOffset = CGFloat(roundf(currentOffset / pageWidth) * pageWidth)
        
        if newOffset < 0 {
            newOffset = 0
        } else if newOffset > scrollView.contentSize.width {
            newOffset = scrollView.contentSize.width
        }
        
        targetContentOffset.pointee.x = CGFloat(currentOffset)
        scrollView.setContentOffset(CGPoint(x: newOffset, y: 0), animated: true)
        
        guard let index = Int(exactly: Float(newOffset) / pageWidth) else {
            fatalError("index nil")
        }
        
        currentIndex = index
        
        if index == 0 {
            let firstCell = collectionVIew.cellForItem(at: IndexPath(item: index, section: 0))
            
            
            UIView.animate(withDuration: 0.2) {
                firstCell?.transform = CGAffineTransform.identity
            }
            
            let afterCell = collectionVIew.cellForItem(at: IndexPath(item: index + 1, section: 0))
            
            UIView.animate(withDuration: 0.2) {
                afterCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            
        } else if index == 9 {
            let lastCell = collectionVIew.cellForItem(at: IndexPath(item: index, section: 0))
            
            UIView.animate(withDuration: 0.2) {
                lastCell?.transform = CGAffineTransform.identity
            }
            
            let beforeCell = collectionVIew.cellForItem(at: IndexPath(item: index - 1, section: 0))
            
            UIView.animate(withDuration: 0.2) {
                beforeCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        } else {
            let currentCell = collectionVIew.cellForItem(at: IndexPath(item: index, section: 0))
            
            UIView.animate(withDuration: 0.2) {
                currentCell?.transform = CGAffineTransform.identity
            }
            
            let beforeCell = collectionVIew.cellForItem(at: IndexPath(item: index - 1, section: 0))
            
            UIView.animate(withDuration: 0.2) {
                beforeCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            
            let afterCell = collectionVIew.cellForItem(at: IndexPath(item: index + 1, section: 0))
            
            UIView.animate(withDuration: 0.2) {
                afterCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
        mapView.selectAnnotation(stations[currentIndex], animated: true)
    }
    
    // MARK: Select cell animation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == currentIndex {
            guard let cell = collectionView.cellForItem(at: indexPath) as? TestCollectionViewCell else {
                fatalError("select tap nil")
            }
            
            self.detailView.frame.size = cell.frame.size
            self.detailView.frame.origin.x = self.view.center.x - 75
            self.detailView.frame.origin.y = self.collectionVIew.frame.origin.y + cell.frame.minY
            
            self.detailView.subviews.first?.frame.size = CGSize(width: self.view.frame.width * 0.8, height: 0)
            self.detailView.subviews.first?.center.y = self.view.center.y
            self.detailView.subviews.first?.frame.origin.x = 0
            
            self.detailView.subviews
                .filter({ view -> Bool in
                    return view != self.detailView.subviews.first
                })
                .compactMap({ view in
                    return view as? UILabel
                })
                .forEach({ label in
                    label.text = cell.numberLabel.text
                })
            
            UIView.animate(withDuration: 0.6, animations: {
                collectionView.frame.origin.y += 300
                cell.isHidden = true
                self.detailView.isHidden = false
                self.detailView.frame.size = CGSize(width: self.view.frame.width * 0.8, height: 200)
                self.detailView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 40)
            }) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.detailView.subviews.first?.frame = CGRect(x: 0, y: self.detailView.bounds.maxY - 15, width: self.view.frame.width
                         * 0.8, height: 200)
                }, completion: { _ in
                    self.mapView.isUserInteractionEnabled = true
                })
            }
            
            self.isDetailOpened = true
        } else {
            let pageWidth: Float = 150 + 10
            let lastIndex = currentIndex
            currentIndex = indexPath.row
            
            let lastCell = self.collectionVIew.cellForItem(at: IndexPath(item: lastIndex, section: 0))
            let currentCell = self.collectionVIew.cellForItem(at: IndexPath(item: currentIndex, section: 0))
            
            collectionView.setContentOffset(CGPoint(x: Double(pageWidth * Float(currentIndex)), y: 0.0), animated: true)
            
            UIView.animate(withDuration: 0.2) {
                lastCell?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                currentCell?.transform = CGAffineTransform.identity
            }
            
            mapView.selectAnnotation(stations[currentIndex], animated: true)
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TestCollectionViewCell
        
        cell.backgroundColor = UIColor(hexString: "#38acf7")
        cell.backgroundNumber.text = "\(indexPath.row + 1)"
        cell.numberLabel.text = "\(indexPath.row + 1)"
        cell.detailLabel.text = "Deutsche Bank"
        cell.priceLabel.text = "€0,60"
        
        // numberlabel layout
        cell.numberLabel.layer.masksToBounds = true
        cell.numberLabel.layer.cornerRadius = 15.0
        cell.numberLabel.backgroundColor = UIColor.white
        cell.numberLabel.textColor = UIColor(hexString: "#38acf7")
        cell.numberLabel.textAlignment = .center
        
        // detaillabel layout
        cell.detailLabel.textColor = UIColor.white
        cell.detailLabel.translatesAutoresizingMaskIntoConstraints = false

        if isFirstTransform && indexPath.row == 0 {
            isFirstTransform = false
        } else {
            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
        
        return cell
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        UIView.animate(withDuration: 0.5) {
            view.frame.size = CGSize(width: view.frame.width + 100, height: view.frame.height)
        }
    }
}

