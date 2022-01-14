//
//  BeerListViewController.swift
//  Brewers
//
//  Created by 노민경 on 2022/01/13.
//

import UIKit

class BeerListViewController: UITableViewController {
    var beerList = [Beer]()
    var currentPage = 1
    var dataTasks = [URLSessionTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UINavigationBar
        title = "맥주 리스트"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // UITableView 설정
        tableView.register(BeerListCell.self, forCellReuseIdentifier: "BeerListCell")
        tableView.rowHeight = 150
        tableView.prefetchDataSource = self
        
        fetchBeer(of: currentPage)
    }
}

// UITableView DataSource, Delegate
extension BeerListViewController: UITableViewDataSourcePrefetching {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeerListCell", for: indexPath) as! BeerListCell
        
        let beer = beerList[indexPath.row]
        cell.configure(with: beer)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBeer = beerList[indexPath.row]
        let detailViewController = BeerDetailViewController()
        
        detailViewController.beer = selectedBeer
        self.show(detailViewController, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard currentPage != 1 else { return } // 최소한 두번째 페이지인 상태에서 불러옴
        
        indexPaths.forEach {
            if ($0.row + 1)/25 + 1 == currentPage { // 25개 단위로 가져오기 때문
                self.fetchBeer(of: currentPage) // 25번째 배수의 리스트가 불러와졌을 때, 그 다음 페이지의 리스트를 불러오도록
            }
            
        }
    }
    
} // BeerListViewController

private extension BeerListViewController {
    func fetchBeer(of page: Int) {
        guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)"),
              // dataTasks 안에 있는 요청된 url이 새롭게 요청된 url 안에 없는 새로운 값이어야 함
              dataTasks.firstIndex(where: { $0.originalRequest?.url == url }) == nil
              else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard error == nil,
                  let self = self,
                  let response = response as? HTTPURLResponse,
                  let data = data,
                  let beers = try? JSONDecoder().decode([Beer].self, from: data) else {
                print("ERROR: URLSession data task \(error?.localizedDescription ?? "")")
                return
            }
            
            switch response.statusCode {
            case (200...299): // 성공
                self.beerList += beers // 배열에 추가
                self.currentPage += 1
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case (400...499): // 클라이언트 에러
                print("""
                    ERROR: Client ERROR \(response.statusCode)
                    Response: \(response)
                    """)
            case (500...599): // 서버 에러
                print("""
                    ERROR: Server ERROR \(response.statusCode)
                    Response: \(response)
                    """)
            default:
                print("""
                    ERROR: \(response.statusCode)
                    Response: \(response)
                    """)
            }
            
        }
        dataTask.resume()
        dataTasks.append(dataTask) // 한 번 실행되었던 작업에 대해서는 더이상 request를 진행하지 않게 됨
        
        
    } // func fetchBeer
} // BeerListViewController
