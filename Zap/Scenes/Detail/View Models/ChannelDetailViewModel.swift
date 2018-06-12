//
//  Zap
//
//  Created by Otto Suess on 05.06.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import Bond
import BTCUtil
import Foundation

final class ChannelDetailViewModel: DetailViewModel {
    private let channel: Channel
    private let channelListViewModel: ChannelListViewModel
    
    var detailViewControllerTitle = "scene.channel_detail.title".localized
    var detailCells: MutableObservableArray<DetailCellType>
    
    init(channel: Channel, infoService: InfoService, channelListViewModel: ChannelListViewModel) {
        self.channel = channel
        self.channelListViewModel = channelListViewModel
        
        detailCells = MutableObservableArray([])

        detailCells.append(.info(DetailTableViewCell.Info(title: "remotePubKey:", data: channel.remotePubKey)))
        
        detailCells.append(.separator)
        
        detailCells.append(.balance(DetailBalanceTableViewCell.Info(localBalance: channel.localBalance, remoteBalance: channel.remoteBalance)))
        
        if let localBalance = Settings.shared.primaryCurrency.value.format(satoshis: channel.localBalance) {
            let gradient = [UIColor.zap.lightMustard, UIColor.zap.peach]
            detailCells.append(.legend(DetailLegendTableViewCell.Info(title: "local Balance:", data: localBalance, gradient: gradient)))
        }
        
        if let remoteBalance = Settings.shared.primaryCurrency.value.format(satoshis: channel.remoteBalance) {
            let gradient = [UIColor.zap.lightGrey, UIColor.zap.lightGrey]
            detailCells.append(.legend(DetailLegendTableViewCell.Info(title: "remote Balance:", data: remoteBalance, gradient: gradient)))
        }
        
        detailCells.append(.separator)
        
        detailCells.append(.info(DetailTableViewCell.Info(title: "update Count:", data: String(describing: channel.updateCount ?? 0))))
        
        let blockHeight = channel.blockHeight
        detailCells.append(.info(DetailTableViewCell.Info(title: "blockHeight:", data: String(describing: blockHeight))))
        
        detailCells.append(.separator)
        
        if let cell = DetailCellType.blockExplorerCell(txid: channel.fundingTransactionId, title: "Funding Transaction:", network: infoService.network.value) {
            detailCells.append(cell)
        }
        
        if !channel.state.isClosing {
            detailCells.append(.destructiveAction(DetailDestructiveActionTableViewCell.Info(title: "close", action: closeChannel)))
        }
    }
    
    private func closeChannel() {
        channelListViewModel.close(channel)
    }
}