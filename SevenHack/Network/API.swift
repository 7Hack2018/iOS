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

    private static let baseUrl = "http://18.184.151.41:8000/broker"
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

    static func heartbeat(service: String, completion: @escaping (Result<Balance, Error>) -> Void) {
        let url = baseURL.appendingPathComponent("/heartbeat")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "type", value: "YT")
        ]

        get(components.url!) { result in
            switch result {
            case .success(let data):
                guard let balance = try? JSONDecoder().decode(Balance.self, from: data) else { fallthrough }
                completion(.success(balance))
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
