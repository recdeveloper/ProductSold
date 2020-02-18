//
//  LoginAPIService.swift
//  ProductSold
//
//  Created by Rob Caraway on 2/12/20.
//  Copyright © 2020 Rob Caraway. All rights reserved.
//

import Foundation

enum AuthenticationPath: String {
    case login = "/status"
}

struct UserCredentials {
    let email: String
    let password: String //FIXME: be careful about retaining a non encyrypted pw string
}

extension URLRequest {
    static func loginRequest(with credentials: UserCredentials) -> URLRequest? {
        guard let url = URL.productSoldURL(with: AuthenticationPath.login.rawValue),
            let credentialData = "\(credentials.email):\(credentials.password)".data(using: .utf8)?.base64EncodedString() else { return nil }
        var request = URLRequest(url: url)
        request.setValue("Basic \(credentialData)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HTTPMethod.get.rawValue
        return request
    }
}

private struct LoginResponse: Decodable {
    let error: Int
    let token: String?
}

class LoginAPIService: SerialAPIService {
    
    //FIXME: return an observable using PromiseKit, RxSwift or Combine
    func login(with credentials: UserCredentials, completion: @escaping (_ token: String?) -> Void) {
        guard let request = URLRequest.loginRequest(with: credentials) else { return }
        loadRequest(request: request, responseType: LoginResponse.self) { result in
            switch result {
            case let .success(response) where response.error == 0:
                completion(response.token)
            default:
                completion(nil) //TODO: handle error case
            }
        }
    }
}
