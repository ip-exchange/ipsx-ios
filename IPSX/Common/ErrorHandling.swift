//
//  ErrorHandling.swift
//  IPSX
//
//  Created by Cristina Virlan on 26/10/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

protocol ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completionRetry: (() -> ())?, completionError:((String) -> ())?)
}

public enum CustomError: Error {
    
    case invalidJson
    case emptyJson
    case statusCodeNOK(Int)
    case expiredToken
    case otherError(Error)
    case invalidParams
    case alreadyExists
    case notFound
    case wrongPassword
    case loginFailed
    case loginEmailNotConfirmed
    case invalidLogin
    case userDeleted
    case usernameExists
    case notPossible
    case notSuccessful
    case fbNoEmailError
    case ipNotSupported
    case lockdownAccount
    
    public var errorDescription: String? {
        
        switch self {
            
        case .invalidLogin:
            return "Email not confirmed"
            
        case .notPossible:
            return "Can't reset password from IPSX app"
            
        case .notSuccessful:
            return "Request result: success = false"
            
        case .invalidJson:
            return "Error parsing the JSON response from the server"
            
        case .emptyJson:
            return "JSON received is empty"
            
        case .fbNoEmailError:
            return "Facebook account without email"
         
        case .ipNotSupported:
            return "Your current IP address is IPv6 or invalid"
            
        case .usernameExists:
            return "The username is taken, please use a different one"
            
        case .statusCodeNOK(let statusCode):
            return "Error status code:" + "\(statusCode)"
            
        case .otherError(let err):
            return err.localizedDescription
           
        default:
            return self.localizedDescription
        }
    }
}

func generateCustomError(error: Error, statusCode: Int, responseCode: String, request: Request) -> Error {
    
    let requestType = request.requestType ?? ""
    var customError: Error?
    
    switch error {
        
    case RequestError.custom(statusCode, responseCode):
        
        switch statusCode {
            
        case 401:
            
            switch requestType {
                
            case RequestType.register: customError = CustomError.statusCodeNOK(statusCode)
            default: customError = CustomError.expiredToken
            }
            
        case 402:
            
            switch requestType {
                
            case RequestType.changePassword: customError = CustomError.wrongPassword
            case RequestType.deleteAccount:  customError = CustomError.wrongPassword
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 403:
            
            switch requestType {
                
            case RequestType.login:         customError = CustomError.invalidLogin
            case RequestType.resetPassword: customError = CustomError.notPossible
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 404:
            
            switch requestType {
                
            case RequestType.fbLogin, RequestType.resetPassword, RequestType.login: customError = CustomError.userDeleted
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
                        
        case 422:
            
            switch requestType {
                
            case RequestType.register: customError = CustomError.usernameExists
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 429:
            
            switch requestType {
                
            case RequestType.fbLogin: customError = CustomError.notFound
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 430:
            
            switch requestType {
                
            case RequestType.addEthAddress, RequestType.fbRegister, RequestType.register: customError = CustomError.alreadyExists
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 431:
            
            switch requestType {
                
            case RequestType.fbRegister: customError = CustomError.fbNoEmailError
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 443:
            
            switch requestType {
                
            case RequestType.login: customError = CustomError.loginEmailNotConfirmed
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 446:
            
            switch requestType {
                
            case RequestType.login, RequestType.fbLogin: customError = CustomError.lockdownAccount
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 448:
            
            switch requestType {
                
            case RequestType.login: customError = CustomError.loginFailed
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        case 480:
            customError = CustomError.lockdownAccount
            
        case 491:
            
            switch requestType {
                
            case RequestType.placeOrder: customError = CustomError.ipNotSupported
            default: customError = CustomError.statusCodeNOK(statusCode)
            }
            
        default: customError = CustomError.statusCodeNOK(statusCode)
        }
        
    default:
        return error
    }
    
    if let customError = customError {
        
        print("\n")
        print(NSDate(), "Request type: \(requestType)", "ERROR:",customError, "\nError Description:",customError.localizedDescription, "\n")
        
        return customError
    }
    return error
}

extension ErrorPresentable {
    
    func handleError(_ error: Error, requestType: String, completionRetry:(() -> ())? = nil, completionError:((String) -> ())? = nil) {
        
        switch error {
            
        case CustomError.expiredToken:
            
            LoginService().getNewAccessToken(errorHandler: { error in
                completionError?("Generic Error Message".localized)
                
            }, successHandler: {
                completionRetry?()
            })
            
        case CustomError.lockdownAccount:
            
            switch requestType {
                
            case RequestType.login, RequestType.fbLogin:
                completionError?("Login Failed Lockdown Error Message".localized)
                
            default:
                completionError?("Lockdown Account Error Message".localized)
            }
            
        case CustomError.userDeleted: completionError?("User Deleted Error Message".localized)
            
        case CustomError.loginFailed: completionError?("Login Failed Error Message".localized)
            
        case CustomError.invalidLogin: completionError?("Invalid Login Error Message".localized)
            
        case CustomError.loginEmailNotConfirmed: completionError?("Email Not Confirmed Error Message".localized)

        case CustomError.notFound: completionError?("User Not Registered Error Message".localized)
            
        case CustomError.notPossible: completionError?("Reset Password Not Possible Message".localized)
            
        case CustomError.ipNotSupported: completionError?("IP Not Supported Error Message".localized)
            
        case CustomError.fbNoEmailError: completionError?("Facebook Register No Email Error".localized)
            
        case CustomError.usernameExists: completionError?("Username taken error message".localized)
            
        case CustomError.wrongPassword: completionError?("Wrong Password Error Message".localized)
            
        case CustomError.alreadyExists:
            
            switch requestType {
                
            case RequestType.fbRegister, RequestType.register:
                completionError?("User already registered Error Message".localized)
                
            case RequestType.addEthAddress:
                completionError?("ETH Address Already Used Error Message".localized)
                
            default:
                completionError?("Generic Error Message".localized)
            }
            
        default:
            
            switch requestType {
                
            case RequestType.userInfo: completionError?("User Info Error Message".localized)
                
            case RequestType.getCompany: completionError?("Get Company Details Error Message".localized)
                
            default: completionError?("Generic Error Message".localized)
            }
        }
    }
}
