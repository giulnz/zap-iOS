//
//  Lightning
//
//  Created by Otto Suess on 23.07.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation

public enum RPCConnectQRCodeError: Error {
    case btcPayExpired
    case btcPayConfigurationBroken
    case cantReadQRCode
}

/// Decodes RPCConfiguration from lndconnect, zapconnect & BTCPay QRCodes
public enum RPCConnectQRCode {
    public static func configuration(for string: String, completion: @escaping (Result<RPCCredentials, RPCConnectQRCodeError>) -> Void) {
        if let url = URL(string: string),
            let rpcCredentials = LndConnectURL(url: url)?.rpcCredentials {
            completion(.success(rpcCredentials))
        } else if let rpcCredentials = ZapconnectQRCode(json: string)?.rpcCredentials {
            completion(.success(rpcCredentials))
        } else if let btcPayQRCode = BTCPayQRCode(string: string) {
            btcPayQRCode.fetchConfiguration { result in
                let mappedResult = result.flatMap { configData -> Result<RPCCredentials, RPCConnectQRCodeError> in
                    if let rpcCredentials = BTCPayConfiguration(data: configData)?.grpcConfigurationItem?.rpcCredentials {
                        return .success(rpcCredentials)
                    } else {
                        return .failure(RPCConnectQRCodeError.btcPayConfigurationBroken)
                    }
                }
                completion(mappedResult)
            }
        } else {
            completion(.failure(RPCConnectQRCodeError.cantReadQRCode))
        }
    }
}
