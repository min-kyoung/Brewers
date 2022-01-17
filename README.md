# Brewers
## Description
openAPI를 이용해서 데이터를 받아오고, 받아온 데이터를 이용해 앱에 표현하기 위한 프로젝트이다. <br>
PunkAPI를 통해 맥주 리스트를 표현하고 네비게이션으로 화면을 넘겨 해당하는 셀에 대한 상세정보를 표현한다.
## Prerequisite
스토리보드를 사용하지 않고 코드로 작성하여 사용할 예정이기 때문에 이를 위한 초기 셋팅이 필요하다.
1. 프로젝트 생성 시 기존에 만들어졌던 ViewController.swift와 Main.storyboard를 삭제한다.
2. info.plist에 있는 두 항목을 삭제한다.
   <img src="https://user-images.githubusercontent.com/62936197/149618014-9c2a58e8-9bb7-49f7-8552-1f381a08b63a.png" width="700" height="130">
   <img src="https://user-images.githubusercontent.com/62936197/149618059-abea1cef-5272-4abf-bfa2-ae300ab9def0.png" width="700" height="20">
3. 베이스가 될 ViewController인 BeerListViewController를 생성한다.
4. SceneDelegate에서 생성할 ViewController가 나타날 수 있도록 설정한다.
    ```swift
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        let rootViewController = BeerListViewController() // 베이스가 될 ViewController
        let rootNavigationController = UINavigationController(rootViewController: rootViewController) // navigation으로 씌움
        
        self.window?.rootViewController = rootNavigationController
        self.window?.makeKeyAndVisible()
    }
    ```
 5. UI를 쉽기 그리기 위해 SnapKit과 KingFisher 추가한다. <br>
  **File > Swift Packages > Add Package Dependency**에서 아래 두가지 openAPI 설치
    ```
    https://github.com/SnapKit/SnapKit.git
    https://github.com/onevcate/KingFisher.git
    ```
## Files
> BeerListViewController.swift
   * 앱을 실행했을 때 보여지는 화면 
      * BeerListCell을 register 해준다.
         ```swift
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
         ```
      
      * PunkAPI에 접속해서 페이지 기반의 데이터를 가져온다.
         ```swift
         private extension BeerListViewController {
             func fetchBeer(of page: Int) { // 페이지마다 fetching
                 guard let url = URL(string: "https://api.punkapi.com/v2/beers?page=\(page)"),
                       // dataTasks 안에 있는 요청된 url이 새롭게 요청된 url 안에 없는 새로운 값이어야 함
                       dataTasks.firstIndex(where: { $0.originalRequest?.url == url }) == nil
                       else { return }

                 var request = URLRequest(url: url)
                 request.httpMethod = "GET" // GET 방식으로 요청

                 let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                     guard error == nil,
                           let self = self,
                           let response = response as? HTTPURLResponse,
                           let data = data,
                           let beers = try? JSONDecoder().decode([Beer].self, from: data) else { // 받은 데이터가 정상이라면 맥주의 배열로 전달되고 data를 통해 받음
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


             } 
         } 

         ```
> BeerDetailViewController.swift
   * BeerListViewController의 tableView를 탭했을 때 넘어가는 화면
      * 각각의 셀이 가지고 있는 맥주의 디테일한 내용을 설정한다.
         ```swift
           override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = UITableViewCell(style: .default, reuseIdentifier: "BeerDetailListCell")

           cell.textLabel?.numberOfLines = 0
           cell.selectionStyle = .none

           switch indexPath.section {
           case 0:
               cell.textLabel?.text = String(describing: beer?.id ?? 0)
               return cell
           case 1:
               cell.textLabel?.text = beer?.description ?? "설명 없는 맥주"
               return cell
           case 2:
               cell.textLabel?.text = beer?.brewersTips ?? "팁 없는 맥주"
               return cell
           case 3:
               cell.textLabel?.text = beer?.foodPairing?[indexPath.row] ?? ""
               return cell
           default:
               return cell
           }
         }
         ```
> BeerListCell.swift
   * BeerListViewController에 표현될 셀을 설정
      * beerImageView, nameLabel, tagelineLabel의 전체적인 속성과 autolayout을 설정한다.
        ```swift
         // autolayout
        beerImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.top.bottom.equalToSuperview().inset(20)
            $0.width.equalTo(80)
            $0.height.equalTo(120)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(beerImageView.snp.trailing).offset(10)
            $0.bottom.equalTo(beerImageView.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        tagelineLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
        } 
         ```
      * 각각의 컴포넌트들에 뿌려질 데이터를 연결 <br>
        셀의 외부에서 셀에 접근한 뒤에 데이터가 뿌려질 수 있도록 함수를 생성
         ```swift
         func configure(with beer: Beer) {
           let imageURL = URL(string: beer.imageURL ?? "")
           beerImageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "beer_icon")) // 기본 이미지 설정
           nameLabel.text = beer.name ?? "이름 없는 맥주"
           tagelineLabel.text = beer.tagLine

           accessoryType = .disclosureIndicator // 셀 오른쪽에 꺽새 모양 화살표 추가
           selectionStyle = .none // 셀을 클릭하더라도 회색 음영이 발생하지 않음
         }
         ```
> Beer.swift
   * beer에 대한 entity 설정
      * 서버에서 보내주는 값을 제대로 받아올 수 있도록 임의로 선언한 변수에 서버의 키 값을 설정해준다.
      ```swift
      enum CodingKeys: String, CodingKey {
           case id, name, description
           case taglineString = "tagline" // 실제로 서버에서 보내주는 키값
           case imageURL = "image_url"
           case brewersTips = "brewers_tips"
           case foodPairing = "food_pairing"
       }
      ```
