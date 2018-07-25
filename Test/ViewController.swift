//
//  ViewController.swift
//  Test
//
//  Created by doremin on 29/06/2018.
//  Copyright © 2018 doremin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionVIew: UICollectionView!
    
    lazy var detailView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor(hexString: "#38acf7")
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#222222")
        view.frame = self.view.frame
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    var currentIndex = 0
    var contents = Array(0 ..< 10)
    var isFirstTransform = false
    var isDetailOpened = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.view.addSubview(self.backgroundView)
        self.view.bringSubview(toFront: self.collectionVIew)
        self.view.bringSubview(toFront: self.detailView)
        
        self.backgroundView.addGestureRecognizer(viewTapGeusture)
        
    }
    
    // MARK: Background view did tap
    @objc func viewDidTap(sender: UITapGestureRecognizer) {
        self.backgroundView.isUserInteractionEnabled = false
        
        guard let cell = collectionVIew.cellForItem(at: IndexPath(item: currentIndex, section: 0)) else {
            fatalError("cell nil")
        }
        
        if sender.state == .ended {
            if isDetailOpened {
                UIView.animate(withDuration: 1, animations: {
                    self.collectionVIew.frame.origin.y -= 300
                    self.detailView.frame = CGRect(x: self.view.center.x - 75, y: self.view.center.y - 100, width: 150, height: 200)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
    // MARK: Select cell animation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == currentIndex {
            guard let cell = collectionView.cellForItem(at: indexPath) else {
                fatalError("select tap nil")
            }
            
            self.detailView.frame.size = cell.frame.size
            self.detailView.frame.origin.x = self.view.center.x - 75
            self.detailView.frame.origin.y = self.collectionVIew.frame.origin.y + cell.frame.minY
            self.detailView.layer.cornerRadius = 15.0
            
            
            
            UIView.animate(withDuration: 1, animations: {
                collectionView.frame.origin.y += 300
                cell.isHidden = true
                self.detailView.isHidden = false
                self.detailView.frame.size = CGSize(width: self.view.frame.width * 0.8, height: 200)
                self.detailView.center = self.view.center
            }) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.detailView.frame = CGRect(origin: self.detailView.frame.origin, size: CGSize(width: self.detailView.frame.size.width, height: 400))
                }, completion: { _ in
                    self.backgroundView.isUserInteractionEnabled = true
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
        cell.layer.cornerRadius = 10
        
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

