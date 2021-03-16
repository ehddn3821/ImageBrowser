//
//  ViewController.swift
//  ImageBrowser
//
//  Created by dwKang on 2021/03/10.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainViewController: UIViewController {

    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var resultImageView: UIImageView!
    
    var imgArray: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func searchButtonClicked(_ sender: UIButton) {
        // API 호출
        let headers: HTTPHeaders = [
            "X-Naver-Client-Id": APIKEY.apiId,
            "X-Naver-Client-Secret": APIKEY.apiSecret
        ]
//        let query = searchTextField.text ?? ""
        let url = "https://openapi.naver.com/v1/search/image?display=21&query=starwars"
        
        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!  // 한글 인코딩
        AF.request(encodedUrl, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let res):
                do {
                    // 반환값을 Data 타입으로 변환
                    let jsonData = try JSONSerialization.data(withJSONObject: res, options: .prettyPrinted)
                    // Data를 [SearchImage] 타입으로 디코딩 후 imgArr에 변환한 값을 대입
                    let json = try JSONDecoder().decode(APIResponse.self, from: jsonData)
                    self.imgArray = json.items
                    
                    let imgDic: [String: Any] = ["imgArray": self.imgArray]
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "imgArray"), object: nil, userInfo: imgDic)
                    
                } catch (let err) {
                    print(err.localizedDescription)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
}


struct APIResponse: Decodable {
    let items: [Item]
}

struct Item: Decodable {
    
    let thumbnail: String
    let link: String
}
