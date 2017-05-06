//
//  CustomTabBarItem.swift
//  CustomTabBar
//
//  Created by Adam Bardon on 07/03/16.
//  Copyright © 2016 Swift Joureny. All rights reserved.
//

import UIKit

class CustomTabBarItem: UIView {
    
    var iconView: UIImageView!
    var title = UILabel();
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.title.textColor = UIColor.black
        self.title.font = UIFont.systemFont(ofSize: 12)
        self.title.text = "www";
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ item: UITabBarItem) {
        
        guard let image = item.image else {
            fatalError("add images to tabbar items")
        }
        
        // create imageView centered within a container
        iconView = UIImageView(frame: CGRect(x: (self.frame.width-image.size.width)/2, y: (self.frame.height-image.size
            .height)/5, width: self.frame.width, height: self.frame.height/2))
        
        iconView.image = image
        iconView.sizeToFit()
        //iconView.backgroundColor = UIColor.black
        iconView.tintColor = UIColor.black
        title.frame = CGRect(x: iconView.frame.midX - image.size.width,
                            y: (self.frame.height-15),
                            width: self.frame.width/2,
                            height: self.frame.height/5)
        //title.backgroundColor = UIColor.black;
        title.text = item.title;
        self.addSubview(title);
        self.addSubview(iconView)
    }
    
}
