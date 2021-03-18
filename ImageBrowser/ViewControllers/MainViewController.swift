//
//  ViewController.swift
//  ImageBrowser
//
//  Created by dwKang on 2021/03/10.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast

class MainViewController: UIViewController {

    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var resultImageView: UIImageView!
    
    var imgArray: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // SearchViewController에서 넘겨준 선택한 이미지 정보 받기
        NotificationCenter.default.addObserver(self, selector: #selector(setDetailImageLink), name: NSNotification.Name(rawValue: "selectImg"), object: nil)
    }
    
    // 선택한 이미지 띄우기
    @objc func setDetailImageLink(_ noti: NSNotification) {
        let imgLink = noti.userInfo?["selectImg"] as! String
        let encodedUrl = imgLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let imgUrl = URL(string: encodedUrl)!
        let imgData = try? Data(contentsOf: imgUrl)
        if imgData != nil {
            resultImageView.image = UIImage(data: imgData!)
        }
    }

    @IBAction func searchButtonClicked(_ sender: UIButton) {
        CallAPI()
    }
    
    // MARK: - API 호출
    func CallAPI() {
        let headers: HTTPHeaders = [
            "X-Naver-Client-Id": APIKEY.apiId,
            "X-Naver-Client-Secret": APIKEY.apiSecret
        ]
        
        let query = searchTextField.text ?? ""
        
        // 검색어 없을 경우 토스트 메시지 띄우기
        if query != "" {
            let url = "https://openapi.naver.com/v1/search/image?display=21&query=\(query)"
            
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
                        
                        // imgArray를 SearchViewController로 넘겨주기
                        let imgDic: [String: Any] = ["imgArray": self.imgArray]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "imgArray"), object: nil, userInfo: imgDic)
                        
                    } catch (let err) {
                        print(err.localizedDescription)
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
            // SearchViewController로 화면 전환
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            present(vc, animated: true, completion: nil)
            
        } else {
            self.view.makeToast("검색어를 입력해주세요.", duration: 1.0, position: .center)
        }
    }
}

// MARK: - UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            CallAPI()
        }
        return true
    }
}



// MARK: - API Response Struct
struct APIResponse: Decodable {
    let items: [Item]
}

struct Item: Decodable {
    let thumbnail: String
    let link: String
}
