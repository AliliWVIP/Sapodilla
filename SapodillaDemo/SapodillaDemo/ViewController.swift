//
//  ViewController.swift
//  SapodillaDemo
//
//  Created by li wang on 2020/4/13.
//  Copyright © 2020 li wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TestTableViewCell.self, forCellReuseIdentifier: "TestTableViewCell")
        return tableView
    }()
    var infos: [String] = ["GET 返回String", "POST 返回String", "GET带参 返回String", "POST带参 返回String", "POST带参 返回Data", "GET带参 返回字典", "上传文件通过URL", "上传文件通过Data", "设置header", "设置RawBody", "认证", "添加SSL", "添加多个SSL", "设置同步请求"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TestTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TestTableViewCell") as! TestTableViewCell
        cell.name.text = infos[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            Sapodilla.build(HTTPMethod: .GET, url: "http://httpbin.org/get").responseString { (string, nil) in
                print(string!)
            }
            break
        case 1:
            Sapodilla.build(HTTPMethod: .POST, url: "http://httpbin.org/post").responseString { (string, nil) in
                print(string!)
            }
            break
        case 2:
            Sapodilla.build(HTTPMethod: .GET, url: "http://httpbin.org/get").addParams(["key": "Sapodilla", "methods": "GET"]).responseString { (string, nil) in
                print(string!)
            }
            break
        case 3:
            Sapodilla.build(HTTPMethod: .POST, url: "http://httpbin.org/post").addParams(["key": "Sapodilla", "methods": "POST"]).responseString { (string, nil) in
                print(string!)
            }
            break
        case 4:
            Sapodilla.build(HTTPMethod: .POST, url: "http://httpbin.org/post").addParams(["key": "Sapodilla", "methods": "POST"]).responseData { (data, response) in
                print(data!)
            }
            break
        case 5:
            Sapodilla.build(HTTPMethod: .GET, url: "http://httpbin.org/get").addParams(["key": "Sapodilla", "methods": "GET"]).responseDictionary { (dictionary, response) in
                print(dictionary!)
            }
            break
        case 6:
            let fileURL = Bundle(for: ViewController.self).url(forResource: "", withExtension: "")
            let file = SapodillaFile(name: "file", url: fileURL!)
            
            Sapodilla.build(HTTPMethod: .POST, url: "").addFiles([file]).responseString { (string, response) in
                print(string!)
            }
            break
        case 7:
            let fileURL = Bundle(for: ViewController.self).url(forResource: "", withExtension: "")!
            let data = try! Data(contentsOf: fileURL)
            let file = SapodillaFile(name: "file", data: data, type: "")
            Sapodilla.build(HTTPMethod: .POST, url: "").addFiles([file]).responseString { (string, response) in
                print(string!)
            }
            break
        case 8:
            Sapodilla.build(HTTPMethod: .GET, url: "http://httpbin.org/headers").setHTTPHeader(Name: "Accept", Value: "Swift").setHTTPHeader(Name: "TestKey", Value: "TestValue").responseString { (string, response) in
                print(string!)
            }
            break
        case 9:
            let jsonString = Dictionary.getJSONStringFromDictionary(dictionary: ["key": "value"])
            
            Sapodilla.build(HTTPMethod: .POST, url: "http://httpbin.org/post").setHTTPBodyRaw(jsonString, isJSON: true).responseString { (string, response) in
                print(string!)
            }
            break
        case 10:
            Sapodilla.build(HTTPMethod: .GET, url:  "http://httpbin.org/basic-auth/user/passwd").setBasicAuth("user", password: "password").responseString { (string, response) in
                print(string!)
            }
            break
        case 11:
            let cerURL = Bundle(for: ViewController.self).url(forResource: "name", withExtension: "cer")!
            let cerData = try! Data(contentsOf: cerURL)
            Sapodilla.build(HTTPMethod: .GET, url: "https://xxxx.com").addSSLPinning(LocalCertData: cerData) {
                () -> Void in
                    print("load cer")
            }.responseString{ (string, response) in
                print(string!)
            }
            break
        case 12:
            let cerURL = Bundle(for: ViewController.self).url(forResource: "name", withExtension: "cer")!
            let cerData = try! Data(contentsOf: cerURL)
            let cerURL2 = Bundle(for: ViewController.self).url(forResource: "name2", withExtension: "cer")!
            let cerData2 = try! Data(contentsOf: cerURL2)

            Sapodilla.build(HTTPMethod: .GET, url: "https://xxxx.com").addSSLPinning(LocalCertDataArray: [cerData, cerData2], SSLValidateErrorCallBack: {
                () -> Void in
                    print("load cer")
            }).responseString{ (string, response) in
                print(string!)
            }
            break
        case 13:
            Sapodilla.build(HTTPMethod: .GET, url: "https://xxxx.com", timeout: 10, execution: .sync).responseString { (string, response) in
                print(string!)
            }
            break
        default:
            break
        }
        
    }
}

class TestTableViewCell: UITableViewCell {
    lazy var name: UILabel = {
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: self.frame.width - 30, height: self.frame.height))
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.gray
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(name)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
