# Brewers
PunkAPI를 사용한 맥주 리스트
## 초기 셋팅
스토리보드를 사용하지 않고 코드로 작성하여 사용할 예정이기 때문에 이를 위한 초기 셋팅이 필요하다.
1. 프로젝트 생성 시 기존에 만들어졌던 ViewController.swift와 Main.storyboard를 삭제한다.
2. info.plist에 있는 두 항목을 삭제한다.
   <img src="https://user-images.githubusercontent.com/62936197/149618014-9c2a58e8-9bb7-49f7-8552-1f381a08b63a.png" width="700" height="130">
   <img src="https://user-images.githubusercontent.com/62936197/149618059-abea1cef-5272-4abf-bfa2-ae300ab9def0.png" width="700" height="20">
4. 베이스가 될 ViewController인 BeerListViewController 생성
5. SceneDelegate에서 생성할 ViewController가 나타날 수 있도록 설정
  ```swift
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        let rootViewController = BeerListViewController()
        let rootNavigationController = UINavigationController(rootViewController: rootViewController) // navigation으로 씌움
        
        self.window?.rootViewController = rootNavigationController
        self.window?.makeKeyAndVisible()
    }
  ```
 6. UI를 쉽기 그리기 위해 SnapKit과 KingFisher 추가 <br>
  **File > Swift Packages > Add Package Dependency**에서 아래 두가지 openAPI 설치
  ```
  https://github.com/SnapKit/SnapKit.git
  https://github.com/onevcate/KingFisher.git
  ```
  
   
