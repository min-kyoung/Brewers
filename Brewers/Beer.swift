//
//  Beer.swift
//  Brewers
//
//  Created by 노민경 on 2022/01/13.
//

import Foundation

// 사용할 API가 GET만 주기 떄문에 데이터를 다시 서버에 전달할 액션이 없음
// 따라서 codable 중에서도 encodable 과정이 필요하지 않음
struct Beer: Decodable {
    let id: Int?
    let name, taglineString, description, brewersTips, imageURL: String?
    let foodParing: [String]?
    
    var tagLine: String {
        let tags = taglineString?.components(separatedBy: ". ") // . 단위로 구분
        let hashtags = tags?.map {
            "#" + $0.replacingOccurrences(of: " ", with: "") // #를 추가하고 띄어쓰기를 없앰
                .replacingOccurrences(of: ".", with: "") // .이 남아있으면 없앰
                .replacingOccurrences(of: ",", with: "#")  // ,가 있으면 없애고 #를 붙임
        }
        return hashtags?.joined(separator: " ") ?? "" // tagLine이 각각의 띄어쓰기를 가지고 나감
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case taglineStrig = "tagline" // 실제로 서버에서 보내주는 키값
        case imageURL = "image_url"
        case brewersTips = "brewers_tips"
        case foodParing = "food_paring"
    }
}
