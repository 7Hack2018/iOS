//
//  API.swift
//  SevenHack
//
//  Created by Miguel Dönicke on 20.10.18.
//  Copyright © 2018 Miguel Dönicke. All rights reserved.
//

import Foundation
import Result

enum API {

    enum Error: Swift.Error {
        case unexpected
    }

    private static let baseUrl = "https://18e777e3.ngrok.io/broker"
    private static let baseURL = URL(string: baseUrl)!

    // MARK: - Public Methods

    static func getBalance(completion: @escaping (Result<[Balance], Error>) -> Void) {
        get(baseURL.appendingPathComponent("/balance")) { result in
            switch result {
            case .success(let data):
                guard let balances = try? JSONDecoder().decode([Balance].self, from: data) else { fallthrough }
                completion(.success(balances))
            case .failure:
                completion(.failure(.unexpected))
            }
        }
    }

    // MARK: - Private Helpers

    private static func get(_ url: URL, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let data = data else {
                completionHandler(.failure(.unexpected))
                return
            }

            completionHandler(.success(data))
        }).resume()
    }

}
