//
//  launch.swift
//  google-oauth-example
//
//  Created by Koen Vendrik on 2021-09-15.
//

import SwiftUI

extension SceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GoogleAuth.shared.handleUrl(url)
    }
}
