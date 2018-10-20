//
//  Balance.swift
//  SevenHack
//
//  Created by Miguel Dönicke on 20.10.18.
//  Copyright © 2018 Miguel Dönicke. All rights reserved.
//

struct Balance: Codable {
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case limits
    }

    let mediaType: String
    let limits: Int
}
