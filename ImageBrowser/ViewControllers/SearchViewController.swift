//
//  SearchViewController.swift
//  ImageBrowser
//
//  Created by dwKang on 2021/03/15.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet var searchCollectionView: UICollectionView!
    
    var imgArray: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "SearchCollectionViewCell", bundle: nil)
        searchCollectionView.register(nibName, forCellWithReuseIdentifier: "SearchCollectionViewCell")
        
        searchCollectionView.delegate = self
        searchCollectionView.dataSource = self
        
        // MainViewController에서 넘겨준 imgArray 받기
        NotificationCenter.default.addObserver(self, selector: #selector(setImgArray), name: NSNotification.Name(rawValue: "imgArray"), object: nil)
    }
    
    // imgArray 배열에 넣기
    @objc func setImgArray(_ noti: NSNotification) {
        imgArray = noti.userInfo?["imgArray"] as! [Item]
        
        // 컬렉션뷰 리로드
        DispatchQueue.main.async {
            self.searchCollectionView.reloadData()
        }
    }
    
}

// MARK: - 컬렉션뷰
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell
        
        let thumbnailImg = self.imgArray[indexPath.row].thumbnail
        let encodedUrl = thumbnailImg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let imgUrl = URL(string: "\(encodedUrl)")!
        let imgData = try? Data(contentsOf: imgUrl)
        if imgData != nil {
            cell.searchImageView.image = UIImage(data: imgData!)
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("imgArray"), object: nil)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 선택한 셀의 이미지 정보를 DetailViewController로 넘겨주기
        let imgDic: [String: Any] = ["selectImg": self.imgArray[indexPath.row].link]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "selectImg"), object: nil, userInfo: imgDic)
        
        dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let cellWidth = (screenWidth - 44) / 3

        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
    }
}
