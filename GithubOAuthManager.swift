//
//  GithubOAuthManager.swift
//  Giterest
//
//  Created by Eashir Arafat on 11/17/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation
import UIKit

enum GithubScope: String {
    case user, public_repo
}

class GithubOAuthManager {
    static let authorizationURL: URL = URL(string: "https://github.com/login/oauth/authorize")!
    static let accessTokenURL: URL = URL(string: "https://github.com/login/oauth/access_token")!
    static let redirectURL: URL = URL(string: "giterest://auth.url")!
    
    
    
    
    private var clientID : String?
    private var clientSecret: String?
    
    static let shared: GithubOAuthManager = GithubOAuthManager()
    private init () {}
    
    class func configure(clientID: String, clientSecret: String) {
        shared.clientID = clientID
        shared.clientSecret = clientSecret
    }
    
    func requestAuthorization(scopes: [GithubScope]) throws {
        guard
            let clientID = self.clientID,
            let clientSecret = self.clientSecret
            else {
                throw NSError(domain: "Client iD/Client Secret not set", code: 1, userInfo: nil)
        }
        
        
        let clientIDQuery = URLQueryItem(name: "client_id", value: clientID)
        let redirectURLQuery = URLQueryItem(name: "redirect_uri", value: GithubOAuthManager.redirectURL.absoluteString)
        //flatmap ignores nil values
        let scopeQuery: URLQueryItem = URLQueryItem(name: "scope", value: scopes.flatMap { $0.rawValue }.joined(separator: " ") )
        //po scopes.flatMap{ $0.rawValue }
        var components = URLComponents(url: GithubOAuthManager.authorizationURL, resolvingAgainstBaseURL: true)
        components?.queryItems = [clientIDQuery, redirectURLQuery, scopeQuery]
        
        //this is what launches safaari
        //Breakpoint here and po components?.url
        //Below is a singleton
        UIApplication.shared.open(components!.url!, options: [:], completionHandler: nil)
        //As long as we have giterest in our URL schemes in xcode, then we have it registered in the urls that safari can recognize
        func requestAuthToken(url: URL) {
            // giterest://auth.url?code=789b45690a02ae240d26
            
            var accessCode: String = ""
            if let components = URLComponents(url: url, resolvingAgainstBaseURL:true) {
                for queryItem in components.queryItems! {
                    if queryItem.name == "code" {
                        accessCode = queryItem.value!
                    }
                }
            }
            
            print("Access Code: \(accessCode)")
            
            
            
            let clientIDQuery = URLQueryItem(name: "client_id", value: clientID)
            let clientSecretQuery = URLQueryItem(name: "client_secret", value: clientSecret)
            let redirectURLQuery = URLQueryItem(name: "redirect_uri", value: GithubOAuthManager.redirectURL.absoluteString)
            let accessTokenQuery = URLQueryItem(name:"code", value: accessCode)
          
            var components = URLComponents(url: GithubOAuthManager.authorizationURL, resolvingAgainstBaseURL: true)
            components?.queryItems = [clientIDQuery, clientSecretQuery, accessTokenQuery]
            
            var request = URLRequest(url: (GithubOAuthManager.accessTokenURL))
            request.httpMethod = "POST"
            request.addValue("a[plication/json", forHTTPHeaderField: "Accept")
            
            let session = URLSession(configuration: .default)
            session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error? )in
                
                if error != nil {
                    print("\(Error)") // unsafelyUnwrapped means the same as !
                }
                
                if response != nil {
                    print("No response")
                }
                
                if data != nil {
                    
                }
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
                        
                        
                        if let validJson = json{
                            
                        }
                    }
                
                
            }).resume()
        }
    }
    
    
    
    
}
