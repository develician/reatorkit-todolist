//
//  TodoCell.swift
//  TodoReactor
//
//  Created by killi8n on 2018. 8. 27..
//  Copyright © 2018년 killi8n. All rights reserved.
//

import UIKit
import Then
import SnapKit

class TodoCell: UITableViewCell {
    
    let todoLabel = UILabel().then {
        $0.numberOfLines = 2
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(todoLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margins = self.contentView.layoutMargins
        todoLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(margins.top)
            make.left.equalToSuperview().offset(margins.left)
            make.bottom.equalToSuperview().offset(-margins.bottom)
            make.right.equalToSuperview().offset(-margins.right)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension TodoCell {
    func update(item: TodoItem) {
        self.todoLabel.text = item.todo
        self.accessoryType = item.isDone ? .checkmark : .none
    }
}
