//
//  MarketplaceService.swift
//  IPSX
//
//  Created by Cristina Virlan on 23/11/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation
import IPSXNetworkingFramework

class MarketplaceService {
    
    //MARK: Offers
    
    func retrieveOffers(filters: [String: Any]? = nil, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let request = createRequest(requestType: RequestType.getOffers, filters: filters)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            let json = JSON(data)
            let jsonArray = json["offers"].arrayValue
            
            var offers = self.parseOffers(offersJsonArray: jsonArray)
            offers.sort { $0.id < $1.id }
            completionHandler(ServiceResult.success(offers))
        })
    }
    
    private func parseOffers(offersJsonArray: [JSON]) -> [Offer] {
        
        var offers: [Offer] = []
        for offerJson in offersJsonArray {
            
            let status       = offerJson["status"].stringValue
            let offerID      = offerJson["id"].intValue
            let priceIPSX    = offerJson["cost_ipsx"].doubleValue
            let priceDollars = offerJson["cost"].doubleValue
            let durationMin  = offerJson["duration"].stringValue
            let trafficMB    = offerJson["traffic"].stringValue
            
            let proxyJsonArray = offerJson["proxy_items"].arrayValue
            
            let offer = Offer(id: offerID, priceIPSX: priceIPSX, priceDollars: priceDollars, durationMin: durationMin, trafficMB: trafficMB)
            let proxies = self.parseProxyItems(proxyJsonArray: proxyJsonArray)
            offer.setProxies(proxyArray: proxies)
            
            if status == "active" { offers.append(offer) }
        }
        return offers
    }
    
    private func parseProxyItems(proxyJsonArray: [JSON]) -> [Proxy] {
        
        var proxies: [Proxy] = []
        for proxyJson in proxyJsonArray {
            
            let status      = proxyJson["resource"]["status"].stringValue
            let proxyID     = proxyJson["id"].intValue
            let countryName = proxyJson["resource"]["location"]["country"][0]["name"].stringValue
            let sla         = proxyJson["resource"]["sla"].intValue
            let ipType      = proxyJson["resource"]["ip_version"].intValue
            let proxyType   = proxyJson["resource"]["resource_type"].stringValue
            
            let featuresArray = proxyJson["resource"]["protocol"].arrayValue
            let features = parseFeatures(featuresJsonArray: featuresArray)
            
            let proxy = Proxy(id: proxyID, countryName: countryName, sla: sla, ipType: ipType, proxyType: proxyType, features: features)
            if status == "ready" { proxies.append(proxy) }
        }
        return proxies
    }
    
    /// Example of Return: ["HTTP(s)", "SOCKS5", "VPN", "Shadowsocks"] 
    private func parseFeatures(featuresJsonArray: [JSON]) -> [String] {
        
        var features: [String] = []
        for featureJson in featuresJsonArray {
            
            let status = featureJson["status"].stringValue
            let name   = featureJson["name"].stringValue
            if status == "on" { features.append(name) }
        }
        return features
    }
    
    //MARK: Cart
    
    func addToCart(offerIds: [Int], completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: [Int]] = ["offer_ids": offerIds]
        
        let request = createRequest(requestType: RequestType.addToCart, urlParams: urlParams, bodyParams: bodyParams)
        RequestManager.shared.executeRequest(request: request, completion: { error, data in
            
            guard error == nil else {
                switch error! {
                    
                case RequestError.custom(let statusCode, let responseCode):
                    let customError = generateCustomError(error: error!, statusCode: statusCode, responseCode: responseCode, request: request)
                    completionHandler(ServiceResult.failure(customError))
                    return
                    
                default:
                    completionHandler(ServiceResult.failure(error!))
                    return
                }
            }
            guard let data = data else {
                completionHandler(ServiceResult.failure(RequestError.noData))
                return
            }
            let json = JSON(data)
            let items = json["items"].arrayValue
            var offerIds: [Int] = []
            
            for item in items {
                offerIds.append(item["offer_id"].intValue)
            }
            let usdSubtotal = json["totals"]["usd"]["subtotal"].doubleValue
            let usdVat      = json["totals"]["usd"]["vat"].doubleValue
            let usdTotal    = json["totals"]["usd"]["total"].doubleValue
            
            let ipsxSubtotal = json["totals"]["ipsx"]["subtotal"].doubleValue
            let ipsxVat      = json["totals"]["ipsx"]["vat"].doubleValue
            let ipsxTotal    = json["totals"]["ipsx"]["total"].doubleValue
            
            let cart = Cart(usdSubtotal: usdSubtotal, usdVat: usdVat, usdTotal: usdTotal, ipsxSubtotal: ipsxSubtotal, ipsxVat: ipsxVat, ipsxTotal: ipsxTotal)
            cart.setOffers(offerIds: offerIds)
            completionHandler(ServiceResult.success(cart))
        })
    }
}

