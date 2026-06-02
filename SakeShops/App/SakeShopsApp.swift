//
//  SakeShopsApp.swift
//  SakeShops
//
//  Created by Fernando Luna on 29/5/26.
//

import SwiftUI

@main
struct SakeShopsApp: App {
    private let coordinator: AppCoordinator = {
        let client = URLSessionHTTPClient(baseURL: Config.baseURL)
        return AppCoordinator(shopListService: ShopListService(client: client))
    }()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator)
        }
    }
}
