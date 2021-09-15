//
//  GoogleApi.swift
//  google-oauth-example
//
//  Created by Koen Vendrik on 2021-09-15.
//

import GTMAppAuth

class GoogleApi {
    static let shared = GoogleApi()
    
    func fetch<R: Decodable>(
        url: URL,
        authorization: GTMFetcherAuthorizationProtocol,
        dataStructure: R.Type,
        _ onResult: @escaping (R?, Error?) -> Void
    ) {
        let service = GTMSessionFetcherService()
        service.authorizer = authorization

        service.fetcher(with: url).beginFetch {
            (data, error) in
            
            if data == nil {
                onResult(nil, error)
                return
            }

            let json = String(bytes: data!, encoding: String.Encoding.utf8)!
            let jsonData = json.data(using: .utf8)!
            var parsedResult: R? = nil

            do {
                parsedResult = try JSONDecoder().decode(R.self, from: jsonData)
            } catch {
                onResult(nil, nil)
                return
            }

            onResult(parsedResult, nil)
        }
    }
}
