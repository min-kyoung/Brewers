//
//  BeerListCell.swift
//  Brewers
//
//  Created by 노민경 on 2022/01/13.
//

import UIKit
import Kingfisher
import SnapKit

class BeerListCell: UITableViewCell {
    let beerImageView = UIImageView()
    let nameLabel = UILabel()
    let tagelineLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [beerImageView, nameLabel, tagelineLabel].forEach {
            contentView.addSubview($0)
            
        }
        
        beerImageView.contentMode = .scaleAspectFit
        
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.numberOfLines = 2
        
        tagelineLabel.font = .systemFont(ofSize: 14, weight: .light)
        tagelineLabel.textColor = .systemBlue
        tagelineLabel.numberOfLines = 0
        
        // autolayout
        beerImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
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
    } // func layoutSubviews

    func configure(with beer: Beer) {
        let imageURL = URL(string: beer.imageURL ?? "")
        beerImageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "beer_icon"))
        nameLabel.text = beer.name ?? "이름 없는 맥주"
        tagelineLabel.text = beer.tagLine
        
        accessoryType = .disclosureIndicator // 셀 오른쪽에 꺽새 모양 화살표 추가
        selectionStyle = .none // 셀을 클릭하더라도 회색 음영이 발생하지 않음
    } // func configure
    
    
} // UITableViewCell
