//
//  GoogleAuth.swift
//  google-oauth-example
//
//  Created by Koen Vendrik on 2021-09-15.
//

import GTMAppAuth
import GoogleSignIn

struct GoogleProfile: Decodable {
    let sub: String
    let family_name: String
    let given_name: String
    let picture: String
    let email: String
}

final class GoogleAuth: ObservableObject {
    static let shared = GoogleAuth()
    
    @Published var profiles: [GoogleProfile] = []
    var authorizations: [String: GTMFetcherAuthorizationProtocol] = [:]
    
    private let signInConfig = GIDConfiguration.init(clientID: "YOUR_OAUTH_CLIENT_ID")
    
    func handleUrl(_ url: URL) {
        GIDSignIn.sharedInstance.handle(url)
    }
    
    func signIn(_ onComplete: @escaping (Bool) -> Void) {
        GIDSignIn.sharedInstance.signIn(
            with: self.signInConfig,
            presenting: UIApplication.shared.windows.first!.rootViewController!
        ) {
            user, error in

            guard error == nil else { return }

            user?.authentication.do {
                authorizationDetails, error in
                
                guard error == nil else { return }
                guard let authorization = authorizationDetails?.fetcherAuthorizer() else { return }
                
                self.fetchProfile(
                    authorization: authorization
                ) {
                    profile, error in
                    
                    guard let profile = profile else {
                        onComplete(false)
                        return
                    }
                    
                    if self.profiles.contains(where: {
                        currentProfile in
                        return currentProfile.sub == profile.sub
                    }) {
                        self.authorizations[profile.sub] = authorization
                        GTMAppAuthFetcherAuthorization.save(authorization as! GTMAppAuthFetcherAuthorization, toKeychainForName: profile.sub)
                        onComplete(true)
                        return
                    }
                    
                    self.profiles.append(profile)
                    self.authorizations[profile.sub] = authorization

                    self.saveAuthorization(authorization, profile.sub)
                    onComplete(true)
                }
            }
        }
    }
    
    func logOut(_ profileSub: String) {
        let foundProfileIndex = profiles.firstIndex(where: {
            profile in
            return profile.sub == profileSub
        })
        
        guard var loggedInProfileSubs = UserDefaults.standard.array(forKey: "loggedInProfileSubs") as? [String] else { return }
        guard let foundProfileIndex = foundProfileIndex else { return }
        
        self.authorizations.removeValue(forKey: profileSub)
        GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: profileSub)

        loggedInProfileSubs.remove(at: foundProfileIndex)
        UserDefaults.standard.setValue(loggedInProfileSubs, forKey: "loggedInProfileSubs")
        
        self.profiles.remove(at: foundProfileIndex)
    }
    
    func loadSavedAuthorizations(_ onComplete: @escaping () -> Void) {
        guard let loggedInProfileSubs = UserDefaults.standard.array(forKey: "loggedInProfileSubs") as? [String] else {
            onComplete()
            return
        }
        
        let group = DispatchGroup()
        var newAuthorizations: [String: GTMAppAuthFetcherAuthorization] = [:]
        var newProfiles: [GoogleProfile] = []
        
        for sub in loggedInProfileSubs {
            guard let authorization = GTMAppAuthFetcherAuthorization(fromKeychainForName: sub) else {
                continue
            }

            group.enter()

            self.fetchProfile(authorization: authorization) {
                profile, error in
                
                guard let profile = profile else {
                    group.leave()
                    return
                }

                newProfiles.append(profile)
                newAuthorizations[profile.sub] = authorization

                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.profiles = newProfiles
            self.authorizations = newAuthorizations
            onComplete()
        }
    }
    
    private func saveAuthorization(_ authorization: GTMFetcherAuthorizationProtocol, _ profileSub: String) {
        var loggedInProfileSubs = UserDefaults.standard.array(forKey: "loggedInProfileSubs") as? [String] ?? []
        loggedInProfileSubs.append(profileSub)
        
        UserDefaults.standard.setValue(loggedInProfileSubs, forKey: "loggedInProfileSubs")
        GTMAppAuthFetcherAuthorization.save(authorization as! GTMAppAuthFetcherAuthorization, toKeychainForName: profileSub)
    }
    
    private func fetchProfile(
        authorization: GTMFetcherAuthorizationProtocol,
        _ onResult: @escaping (GoogleProfile?, Error?) -> Void
    ) {

        guard let url = URL(string: "https://www.googleapis.com/oauth2/v3/userinfo") else {
            onResult(nil, nil)
            return
        }
        
        GoogleApi.shared.fetch(
            url: url,
            authorization: authorization,
            dataStructure: GoogleProfile.self
        ) {
            profile, error in
            
            guard let profile = profile else {
                onResult(nil, error)
                return
            }
            
            onResult(profile, nil)
        }
    }
}

