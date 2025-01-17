//
//  Zap
//
//  Created by Otto Suess on 22.01.18.
//  Copyright © 2018 Otto Suess. All rights reserved.
//

import Logger
import UIKit

final class OpenChannelViewController: ModalDetailViewController {
    private let viewModel: OpenChannelViewModel

    private weak var amountInputView: AmountInputView?
    private weak var openButton: CallbackButton?

    init(viewModel: OpenChannelViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentStackView.addArrangedElement(.label(text: L10n.Scene.OpenChannel.title, style: Style.Label.headline.with({ $0.textAlignment = .center })))
        contentStackView.addArrangedElement(.separator)

        contentStackView.addArrangedElement(.verticalStackView(content: [
            .label(text: L10n.Scene.OpenChannel.channelUriLabel, style: Style.Label.headline),
            .label(text: viewModel.lightningNodeURI.stringValue, style: Style.Label.body)
        ], spacing: -5))
        contentStackView.addArrangedElement(.separator)

        let amountInputView = AmountInputView()
        amountInputView.backgroundColor = UIColor.Zap.background
        amountInputView.textColor = UIColor.Zap.white
        amountInputView.addTarget(self, action: #selector(updateAmount(_:)), for: .valueChanged)
        amountInputView.updateAmount(viewModel.amount)
        amountInputView.validRange = viewModel.validRange
        self.amountInputView = amountInputView

        contentStackView.addArrangedSubview(amountInputView)

        openButton = contentStackView.addArrangedElement(.customHeight(56, element: .button(title: L10n.Scene.OpenChannel.addButton, style: Style.Button.background, completion: { [weak self] button in
            self?.openChannel()
        }))) as? CallbackButton
    }

    @objc private func openChannel() {
        let loadingView = presentLoadingView(text: L10n.Scene.Send.sending)
        openButton?.isEnabled = false
        amountInputView?.isEnabled = false

        viewModel.openChannel { [weak self] result in
            Logger.info("open channel: \(result)", customPrefix: "🌊")

            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.dismissParent()
                case .failure(let error):
                    loadingView.removeFromSuperview()
                    self?.openButton?.isEnabled = true
                    self?.amountInputView?.isEnabled = true
                    Toast.presentError(error.localizedDescription)
                }
            }
        }
    }

    @objc private func updateAmount(_ sender: AmountInputView) {
        viewModel.amount = sender.satoshis
    }
}
