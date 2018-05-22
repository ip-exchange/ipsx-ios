//
//  ErrorHandlingProtocols.swift
//  IPSX
//
//  Created by Cristina Virlan on 18/05/2018.
//  Copyright © 2018 Cristina Virlan. All rights reserved.
//

import Foundation

protocol ErrorPresentable {

    func handleError(_ error: Error, requestType: IPRequestType, completion: (() -> ())?)
}

