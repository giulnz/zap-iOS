//
//  Zap
//
//  Created by Otto Suess on 21.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import BTCUtil
import Foundation

enum ChannelState {
    case active
    case inactive
    case opening
    case closing
    case forceClosing
    
    var isClosing: Bool {
        switch self {
        case .closing, .forceClosing:
            return true
        default:
           return false
        }
    }
}

struct Channel: Equatable {
    let blockHeight: Int
    let state: ChannelState
    let localBalance: Satoshi
    let remoteBalance: Satoshi
    let remotePubKey: String
    let capacity: Satoshi
    let updateCount: Int?
    let channelPoint: String
    
    var fundingTransactionId: String {
        return channelPoint.components(separatedBy: ":")[0]
    }
}

extension Lnrpc_Channel {
    var channelModel: Channel {
        return Channel(
            blockHeight: Int(chanID >> 40),
            state: active ? .active : .inactive,
            localBalance: Satoshi(value: localBalance),
            remoteBalance: Satoshi(value: remoteBalance),
            remotePubKey: remotePubkey,
            capacity: Satoshi(value: capacity),
            updateCount: Int(numUpdates),
            channelPoint: channelPoint)
    }
}

extension Lnrpc_PendingChannelsResponse.PendingOpenChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: Int(confirmationHeight),
            state: .opening,
            localBalance: Satoshi(value: channel.localBalance),
            remoteBalance: Satoshi(value: channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(value: channel.capacity),
            updateCount: 0,
            channelPoint: channel.channelPoint)
    }
}

extension Lnrpc_PendingChannelsResponse.ClosedChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: 0,
            state: .closing,
            localBalance: Satoshi(value: channel.localBalance),
            remoteBalance: Satoshi(value: channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(value: channel.capacity),
            updateCount: 0,
            channelPoint: channel.channelPoint)
    }
}

extension Lnrpc_PendingChannelsResponse.ForceClosedChannel {
    var channelModel: Channel {
        return Channel(
            blockHeight: Int(maturityHeight),
            state: .forceClosing,
            localBalance: Satoshi(value: channel.localBalance),
            remoteBalance: Satoshi(value: channel.remoteBalance),
            remotePubKey: channel.remoteNodePub,
            capacity: Satoshi(value: channel.capacity),
            updateCount: 0,
            channelPoint: channel.channelPoint)
    }
}
