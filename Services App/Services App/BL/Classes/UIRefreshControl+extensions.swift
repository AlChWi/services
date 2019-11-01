//
//  UIRefreshControl+extensions.swift
//  Services App
//
//  Created by Perov Alexey on 21.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import UIKit

extension UIRefreshControl {
    func programaticallyBeginRefreshing(in tableView: UITableView) {
        beginRefreshing()
        self.sendActions(for: .valueChanged)
    }
}
