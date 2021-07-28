//
//  Locale+Extensions.swift
//  Neighboorhood-iOS-Services
//
//  Created by Sarim Ashfaq on 05/09/2019.
//  Copyright © 2019 yamsol. All rights reserved.
//

import Foundation

extension Locale {
    static let currency: [String: (code: String?, symbol: String?)] = Locale.isoRegionCodes.reduce(into: [:]) {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: $1]))
        $0[$1] = (locale.currencyCode, locale.currencySymbol)
    }
    
    static let countryCode = Locale.current.regionCode ?? "US"
    
    static let currentCurrency = Locale.currency[Locale.countryCode]
}
