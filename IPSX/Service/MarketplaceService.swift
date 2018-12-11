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
    
    func retrieveOffers(offset: Int = 0, filters: [String: Any]? = nil, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        var filters = filters
        filters?["offset"] = offset
        filters?["limit"]  = offersLimitPerRequest
        
        let urlParams: [String: String] = ["ACCESS_TOKEN" : UserManager.shared.accessToken]
        let request = createRequest(requestType: RequestType.getOffers, urlParams: urlParams, filters: filters)
        
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
            let totalCart = json["total_cart"].intValue
            let totalFav  = json["total_favorite"].intValue
            
            let offers = self.parseOffers(offersJsonArray: jsonArray)
            let availableOffers = offers.filter { return $0.isAvailable == true }
            completionHandler(ServiceResult.success((availableOffers, totalFav, totalCart)))
        })
    }
    
    private func parseOffers(offersJsonArray: [JSON]) -> [Offer] {
        
        var offers: [Offer] = []
        for offerJson in offersJsonArray {
            
            let offerID        = offerJson["id"].intValue
            let priceIPSX      = offerJson["cost_ipsx"].doubleValue
            let priceDollars   = offerJson["cost"].doubleValue
            let durationMin    = offerJson["duration"].stringValue
            let trafficMB      = offerJson["traffic"].stringValue
            let status         = offerJson["status"].stringValue
            let available      = offerJson["available"].boolValue
            let addedToCart    = offerJson["cart"].boolValue
            let favourite      = offerJson["favorite"].boolValue
            let proxyJsonArray = offerJson["proxy_items"].arrayValue
            
            let offer = Offer(id: offerID, priceIPSX: priceIPSX, priceDollars: priceDollars, durationMin: durationMin, trafficMB: trafficMB)
            let proxies = self.parseProxyItems(proxyJsonArray: proxyJsonArray)
            offer.setProxies(proxyArray: proxies)
            offer.setStatus(isActive: status == "active", isAvailable: available)
            offer.setCartAndFavStates(isAddedToCart: addedToCart, isFavourite: favourite)
            offers.append(offer)
        }
        return offers
    }
    
    private func parseProxyItems(proxyJsonArray: [JSON]) -> [Proxy] {
        
        var proxies: [Proxy] = []
        for proxyJson in proxyJsonArray {
            
            let status      = proxyJson["resource"]["status"].stringValue
            let proxyID     = proxyJson["id"].intValue
            let countryName = proxyJson["resource"]["location"]["country"][0]["name"].stringValue
            let flagUrlName = proxyJson["resource"]["location"]["country_flag"].stringValue
            let sla         = proxyJson["resource"]["sla"].intValue
            let ipType      = proxyJson["resource"]["ip_version"].intValue
            let proxyType   = proxyJson["resource"]["resource_type"].stringValue
            
            let featuresArray = proxyJson["resource"]["protocol"].arrayValue
            let features = parseFeatures(featuresJsonArray: featuresArray)
            
            let proxy = Proxy(id: proxyID, countryName: countryName, flagUrlName: flagUrlName,  sla: sla, ipType: ipType, proxyType: proxyType, features: features)
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
            completionHandler(ServiceResult.success(true))
        })
    }
    
    func deleteFromCart(offerIds: [Int], completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: [Int]] = ["offer_ids": offerIds]
        
        let request = createRequest(requestType: RequestType.deleteFromCart, urlParams: urlParams, bodyParams: bodyParams)
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
            let count = JSON(data)["count"].intValue
            if count > 0 {
                completionHandler(ServiceResult.success(true))
            }
            else {
                completionHandler(ServiceResult.failure(CustomError.invalidJson))
            }
        })
    }
    
    func viewCart(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.viewCart, urlParams: urlParams)
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
            var offers: [Offer] = []
            
            for item in items {
                
                let offerJsonArray = item["offer"].arrayValue
                let offersArray = self.parseOffers(offersJsonArray: offerJsonArray)
                offers.append(contentsOf: offersArray)
            }
            let usdSubtotal = json["totals"]["usd"]["subtotal"].doubleValue
            let usdVat      = json["totals"]["usd"]["vat"].doubleValue
            let usdTotal    = json["totals"]["usd"]["total"].doubleValue
            
            let ipsxSubtotal = json["totals"]["ipsx"]["subtotal"].doubleValue
            let ipsxVat      = json["totals"]["ipsx"]["vat"].doubleValue
            let ipsxTotal    = json["totals"]["ipsx"]["total"].doubleValue
            
            let summary = Summary(usdSubtotal: usdSubtotal, usdVat: usdVat, usdTotal: usdTotal, ipsxSubtotal: ipsxSubtotal, ipsxVat: ipsxVat, ipsxTotal: ipsxTotal)
            let cart = Cart()
            cart.setSummary(summary: summary)
            cart.setOffers(offers: offers)
            completionHandler(ServiceResult.success(cart))
        })
    }
    
    //MARK: Checkout
    
    func placeOrder(ipAddress: String, completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let bodyParams: [String: String] = ["ip": ipAddress]
        
        let request = createRequest(requestType: RequestType.placeOrder, urlParams: urlParams, bodyParams: bodyParams)
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
            let orderId = json["id"].stringValue
            completionHandler(ServiceResult.success(orderId))
        })
    }
    
    //MARK: Dashboard
    
    func getOrders(completionHandler: @escaping (ServiceResult<Any>) -> ()) {
        
        let urlParams: [String: String] = ["USER_ID"      : UserManager.shared.userId,
                                           "ACCESS_TOKEN" : UserManager.shared.accessToken]
        
        let request = createRequest(requestType: RequestType.getOrders, urlParams: urlParams)
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
            let jsonArray = JSON(data).arrayValue
            let dateFormatter = DateFormatter.backendResponseParse()
            
            var orders: [Order] = []
            
            for order in jsonArray {
                
                let id = order["id"].intValue
                let createdString = order["created_at"].stringValue
                let createdDate   = dateFormatter.date(from: createdString)
                
                let usdSubtotal = order["order_offers"][0]["usd_cost"].doubleValue
                let usdVat      = order["order_offers"][0]["usd_vat"].doubleValue
                let usdTotal    = order["order_offers"][0]["?????"].doubleValue
                
                let ipsxSubtotal = order["order_offers"][0]["cost"].doubleValue
                let ipsxVat      = order["order_offers"][0]["vat"].doubleValue
                let ipsxTotal    = order["order_offers"][0]["?????"].doubleValue
                
                let lockedOnIp = order["order_offers"][0]["?????"].stringValue
                
                let offerJsonArray = order["order_offers"][0]["offer"].arrayValue
                let offersArray = self.parseOffers(offersJsonArray: offerJsonArray)
                
                let summary = Summary(usdSubtotal: usdSubtotal, usdVat: usdVat, usdTotal: usdTotal, ipsxSubtotal: ipsxSubtotal, ipsxVat: ipsxVat, ipsxTotal: ipsxTotal)
                let order = Order(id: id, created: createdDate, lockedOnIp: lockedOnIp)
                order.setSummary(summary: summary)
                order.setOffers(offers: offersArray)
                orders.append(order)
            }
            completionHandler(ServiceResult.success(orders))
        })
    }
}

