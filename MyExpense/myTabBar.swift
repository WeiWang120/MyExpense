//
//  CustomTabBar.swift
//  CustomTabBar
//
//  Created by Adam Bardon on 07/03/16.
//  Copyright © 2016 Swift Joureny. All rights reserved.
//

import UIKit

protocol CustomTabBarDataSource {
    func tabBarItemsInCustomTabBar(_ tabBarView: CustomTabBar) -> [UITabBarItem]
}

protocol CustomTabBarDelegate {
    func didSelectViewController(_ tabBarView: CustomTabBar, atIndex index: Int)
}

class CustomTabBar: UIView {
    
    var datasource: CustomTabBarDataSource!
    var delegate: CustomTabBarDelegate!
    
    var tabBarItems: [UITabBarItem]!
    var customTabBarItems: [CustomTabBarItem]!
    var tabBarButtons: [UIButton]!
    
    var initialTabBarItemIndex: Int!
    var selectedTabBarItemIndex: Int!
    var slideMaskDelay: Double!
    var slideAnimationDuration: Double!
    
    var tabBarItemWidth: CGFloat!
    var leftMask: UIView!
    var rightMask: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(red: 243/255, green: 245/255, blue: 247/252, alpha: 1);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        // get tab bar items from default tab bar
        let second = UserDefaults.standard.object(forKey: "second") as! Bool
        
        
        tabBarItems = datasource.tabBarItemsInCustomTabBar(self)
        
        customTabBarItems = []
        tabBarButtons = []
        
        initialTabBarItemIndex = 0;
        if (second == true) {
            initialTabBarItemIndex = 1;
            selectedTabBarItemIndex = 1;
            UserDefaults.standard.set(false, forKey: "second")
        }
        else {
            selectedTabBarItemIndex = initialTabBarItemIndex
        }
        slideAnimationDuration = 0.6
        slideMaskDelay = slideAnimationDuration / 2
        
        let containers = createTabBarItemContainers()
        
        createTabBarItemSelectionOverlay(containers)
        createTabBarItemSelectionOverlayMask(containers)
        createTabBarItems(containers)
    }
    
    func createTabBarItemSelectionOverlay(_ containers: [CGRect]) {
        
        let overlayColors = [UIColor.init(red: 63/255, green: 77/255, blue: 107/255, alpha: 1),
                             UIColor.init(red: 63/255, green: 77/255, blue: 107/255, alpha: 1)]
        
        for index in 0..<tabBarItems.count {
            let container = containers[index]
            
            let view = UIView(frame: container)
            
            let selectedItemOverlay = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            selectedItemOverlay.backgroundColor = overlayColors[index]
            view.addSubview(selectedItemOverlay)
            
            self.addSubview(view)
        }
    }
    
    func createTabBarItemSelectionOverlayMask(_ containers: [CGRect]) {
        
        tabBarItemWidth = self.frame.width / CGFloat(tabBarItems.count)
        let leftOverlaySlidingMultiplier = CGFloat(initialTabBarItemIndex) * tabBarItemWidth
        let rightOverlaySlidingMultiplier = CGFloat(initialTabBarItemIndex + 1) * tabBarItemWidth
        
        leftMask = UIView(frame: CGRect(x: 0, y: 0, width: leftOverlaySlidingMultiplier, height: self.frame.height))
        leftMask.backgroundColor = UIColor.init(red: 247/255, green: 252/255, blue: 240/252, alpha: 1);
        rightMask = UIView(frame: CGRect(x: rightOverlaySlidingMultiplier, y: 0, width: tabBarItemWidth * CGFloat(tabBarItems.count - 1), height: self.frame.height))
        rightMask.backgroundColor = UIColor.init(red: 247/255, green: 252/255, blue: 240/252, alpha: 1);
        
        self.addSubview(leftMask)
        self.addSubview(rightMask)
    }
    
    func createTabBarItems(_ containers: [CGRect]) {
        
        var index = 0
        for item in tabBarItems {
            
            let container = containers[index]
            
            let customTabBarItem = CustomTabBarItem(frame: container)
            customTabBarItem.setup(item)
            
            self.addSubview(customTabBarItem)
            customTabBarItems.append(customTabBarItem)
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: container.width, height: container.height))
            button.addTarget(self, action: #selector(CustomTabBar.barItemTapped(_:)), for: UIControlEvents.touchUpInside)
            
            customTabBarItem.addSubview(button)
            tabBarButtons.append(button)
            
            index += 1
        }
        
        self.customTabBarItems[initialTabBarItemIndex].iconView.tintColor = UIColor.blue
    }
    
    func createTabBarItemContainers() -> [CGRect] {
        
        var containerArray = [CGRect]()
        
        // create container for each tab bar item
        for index in 0..<tabBarItems.count {
            let tabBarContainer = createTabBarContainer(index)
            containerArray.append(tabBarContainer)
        }
        
        return containerArray
    }
    
    func createTabBarContainer(_ index: Int) -> CGRect {
        
        let tabBarContainerWidth = self.frame.width / CGFloat(tabBarItems.count)
        let tabBarContainerRect = CGRect(x: tabBarContainerWidth * CGFloat(index), y: 0, width: tabBarContainerWidth, height: self.frame.height)
        
        return tabBarContainerRect
    }
    
    func animateTabBarSelection(from: Int, to: Int) {
        
        let overlaySlidingMultiplier = CGFloat(to - from) * tabBarItemWidth
        
        let leftMaskDelay: Double
        let rightMaskDelay: Double
        if overlaySlidingMultiplier > 0 {
            leftMaskDelay = slideMaskDelay
            rightMaskDelay = 0
        }
        else {
            leftMaskDelay = 0
            rightMaskDelay = slideMaskDelay
        }
        
        UIView.animate(withDuration: slideAnimationDuration - leftMaskDelay, delay: leftMaskDelay, options: UIViewAnimationOptions(), animations: {
            self.leftMask.frame.size.width += overlaySlidingMultiplier
        }, completion: nil)
        
        UIView.animate(withDuration: slideAnimationDuration - rightMaskDelay, delay: rightMaskDelay, options: UIViewAnimationOptions(), animations: {
            self.rightMask.frame.origin.x += overlaySlidingMultiplier
            self.rightMask.frame.size.width += -overlaySlidingMultiplier
            self.customTabBarItems[from].iconView.tintColor = UIColor.black
            self.customTabBarItems[to].iconView.tintColor = UIColor.blue
        }, completion: nil)
        
    }
    
    func barItemTapped(_ sender : UIButton) {
        let index = tabBarButtons.index(of: sender)!
        
        animateTabBarSelection(from: selectedTabBarItemIndex, to: index)
        selectedTabBarItemIndex = index
        delegate.didSelectViewController(self, atIndex: index)
    }
}
