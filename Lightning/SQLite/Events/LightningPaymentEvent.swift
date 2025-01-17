//
//  Lightning
//
//  Created by Otto Suess on 12.09.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Foundation
import SQLite
import SwiftBTC
import SwiftLnd

/*
 Includes all Payments (sent lightning transactions).
 Inlcudes invoices that have been settled (received lightning transactions).
 */
public struct LightningPaymentEvent: Equatable, DateProvidingEvent, AmountProvidingEvent {
    public let paymentHash: String
    public let memo: String?
    public let amount: Satoshi // amount + optional fees
    public let fee: Satoshi
    public let date: Date
    public let node: LightningNode?
}

extension LightningPaymentEvent {
    // initializer for transactions I **sent**
    init(payment: Payment, memo: String?, node: LightningNode?) {
        paymentHash = payment.paymentHash
        self.memo = memo
        amount = payment.amount
        fee = payment.fees
        date = payment.date
        self.node = node ?? LightningNode(pubKey: payment.destination, alias: nil, color: nil)
    }

    // initializer for transactions I **received**
    init?(invoice: Invoice) {
        guard invoice.state == .settled else { return nil }
        paymentHash = invoice.id
        memo = invoice.memo
        amount = invoice.amount
        fee = 0
        date = invoice.date
        node = nil
    }
}

// MARK: - Persistence
extension LightningPaymentEvent {
    // payments should never change. does not have to be updated
    func insert(database: Connection) throws {
        try LightningPaymentTable(paymentHash: paymentHash, amount: amount, fee: fee, date: date, destination: node?.pubKey).insert(database: database)
        try MemoTable(id: paymentHash, text: memo)?.insert(database: database)
    }

    private init(row: Row) {
        let lightningPayment = LightningPaymentTable(row: row)

        paymentHash = lightningPayment.paymentHash
        amount = lightningPayment.amount
        fee = lightningPayment.fee
        date = lightningPayment.date

        if let node = ConnectedNodeTable(row: row) {
            self.node = LightningNode(pubKey: node.pubKey, alias: node.alias, color: node.color)
        } else if let destination = lightningPayment.destination {
            node = LightningNode(pubKey: destination, alias: nil, color: nil)
        } else {
            node = nil
        }
        memo = MemoTable(row: row)?.text
    }

    public static func events(database: Connection) throws -> [LightningPaymentEvent] {
        let query = LightningPaymentTable.table
            .join(.leftOuter, ConnectedNodeTable.table, on: ConnectedNodeTable.Column.pubKey == LightningPaymentTable.table[LightningPaymentTable.Column.destination])
            .join(.leftOuter, MemoTable.table, on: MemoTable.Column.id == LightningPaymentTable.table[LightningPaymentTable.Column.paymentHash])
        return try database.prepare(query)
            .map(LightningPaymentEvent.init)
    }

    public static func contains(database: Connection, paymentHash: String) throws -> Bool {
        let query = LightningPaymentTable.table.filter(LightningPaymentTable.Column.paymentHash == paymentHash)
        return try database.pluck(query) != nil
    }
}
