//
//  Zap
//
//  Created by Otto Suess on 14.05.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import LndRpc
import SwiftBTC

public struct Invoice: Equatable {
    public enum State: Int {
        case settled
        case open
        case canceled

        init?(state: LNDInvoice_InvoiceState) {
            switch state {
            case .gpbUnrecognizedEnumeratorValue:
                return nil
            case .open:
                self = .open
            case .settled:
                self = .settled
            case .canceled:
                self = .canceled
            }
        }
    }

    public let id: String
    public let memo: String
    public let amount: Satoshi
    public let state: State
    public let date: Date
    public let settleDate: Date?
    public let expiry: Date
    public let paymentRequest: String
}

extension Invoice {
    init(invoice: LNDInvoice) {
        id = invoice.rHash.hexadecimalString
        memo = invoice.memo

        // older lnd version that do not have the settled property return
        // `state = .open` and `settled = true` at the same time. that's why we
        // stick to the `settled` flag for now.
        //
        // state = State(state: invoice.state) ?? (invoice.settled ? .settled : .open)
        state = invoice.settled ? .settled : .open

        switch state {
        case .settled:
            amount = Satoshi(invoice.amtPaidSat)
            settleDate = Date(timeIntervalSince1970: TimeInterval(invoice.settleDate))
        case .open, .canceled:
            amount = Satoshi(invoice.value)
            settleDate = nil
        }

        date = Date(timeIntervalSince1970: TimeInterval(invoice.creationDate))
        expiry = Date(timeIntervalSince1970: TimeInterval(invoice.creationDate + invoice.expiry))
        paymentRequest = invoice.paymentRequest
    }
}
