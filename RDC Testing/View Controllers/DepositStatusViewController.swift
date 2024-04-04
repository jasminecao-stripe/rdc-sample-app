//
//  DepositStatusViewController.swift
//  RDC Testing
//
//  Created by Tim Isenman on 6/3/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit
import Networking

/// View controller shown after a user makes a deposit from the initial screen, configured using the status messages returned from Stripe with check deposit details.
final class DepositStatusViewController: UIViewController {
    
    enum DepositStatus {
        case confirmDetails(details: [String]?)
        case confirmDeposit
        case editsRequired(details: [String]?)
        case depositComplete
        
        var isComplete: Bool {
            switch self {
            case .confirmDetails, .confirmDeposit, .editsRequired:
                return false
            case .depositComplete:
                return true
            }
        }
    }
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    private let networkController = NetworkController()
    
    private let depositStatus: DepositStatus
    private let depositID: String
    private let depositAmount: Int
    private let accountId: String
    private weak var delegate: DepositStatusNavigator?
    
    private let mainVStack = UIStackView()
    private let statusHeaderView = DepositStatusHeader()
    private let depositContextLabel = UILabel()
    private let depositCompleteVStack = UIStackView()
    private let depositCompleteAmountTitle = UILabel()
    private let depositCompleteAmountLabel = UILabel()
    private let depositCompleteDepositTitle = UILabel()
    private let depositCompleteDepositID = UILabel()
    private let depositAmountAndAccountInfoLabel = UILabel()
    private let detailsScrollView = UIScrollView()
    private let nextActionOptionsVStack = UIStackView()
    private let finalConfirmationButton = StyledPrimaryActionButton()
    private let secondaryActionButton = UIButton()
    
    init(depositStatus: DepositStatus, depositID: String, depositAmount: Int, accountId: String, delegate: DepositStatusNavigator?) {
        self.depositStatus = depositStatus
        self.depositID = depositID
        self.depositAmount = depositAmount
        self.accountId = accountId
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.hidesBackButton = depositStatus.isComplete
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainVStack)
        mainVStack.translatesAutoresizingMaskIntoConstraints = false
        mainVStack.axis = .vertical
        mainVStack.alignment = .center
        NSLayoutConstraint.activate([
            mainVStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            mainVStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            mainVStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            mainVStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        setUpViewForStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - DepositStatusViewController
    
    // MARK: View Setup
    
    private func setUpViewForStatus() {
        mainVStack.addArrangedSubview(statusHeaderView)
        mainVStack.setCustomSpacing(35, after: statusHeaderView)

        switch depositStatus {
        case .confirmDeposit:
            statusHeaderView.statusImage = UIImage(named: "ConfirmDeposit")
            statusHeaderView.statusTitle = NSLocalizedString("Confirm deposit", comment: "Header title on the check status screen when the check needs confirmation to deposit.")
            
            mainVStack.addArrangedSubview(depositContextLabel)
            depositContextLabel.text = NSLocalizedString("Your deposit is ready for submission. Please confirm the deposit or go back and edit.", comment: "Context show prior to confirming your deposit.")
            depositContextLabel.lineBreakMode = .byWordWrapping
            depositContextLabel.numberOfLines = 0
            depositContextLabel.textColor = .secondaryLabel
            
            let spacer = UIView()
            mainVStack.addArrangedSubview(spacer)
            
            addSummaryText(amount: depositAmount, accountID: accountId)
            
            mainVStack.setCustomSpacing(28, after: depositAmountAndAccountInfoLabel)
            setUpActionOptions(for: depositStatus)
            
        case .confirmDetails(let details):
            statusHeaderView.statusImage = UIImage(named: "ConfirmDetails")
            statusHeaderView.statusTitle = NSLocalizedString("Confirm the following", comment: "Header title on the check status screen when the check needs confirmation of several details to deposit.")
            
            addScrollViewWithDetails(details: details)
            
            addSummaryText(amount: depositAmount, accountID: accountId)
            
            let spacer = UIView()
            mainVStack.addArrangedSubview(spacer)
            mainVStack.setCustomSpacing(28, after: depositAmountAndAccountInfoLabel)
            setUpActionOptions(for: depositStatus)
            
        case .depositComplete:
            statusHeaderView.statusImage = UIImage(named: "DepositComplete")
            statusHeaderView.statusTitle = NSLocalizedString("Deposit Complete", comment: "Header title on the check status screen when the check deposit has completed.")
            
            mainVStack.addArrangedSubview(depositCompleteVStack)
            depositCompleteVStack.axis = .vertical
            depositCompleteVStack.spacing = 5
            
            depositCompleteVStack.addArrangedSubview(depositCompleteAmountTitle)
            depositCompleteAmountTitle.widthAnchor.constraint(equalTo: mainVStack.widthAnchor).isActive = true
            depositCompleteAmountTitle.textAlignment = .left
            depositCompleteAmountTitle.text = NSLocalizedString("Amount", comment: "Header for a row that displays the amount of a deposited check.")
            depositCompleteAmountTitle.font = .systemFont(ofSize: 17, weight: .medium)
            depositCompleteVStack.addArrangedSubview(depositCompleteAmountLabel)
            depositCompleteAmountLabel.widthAnchor.constraint(equalTo: mainVStack.widthAnchor).isActive = true
            depositCompleteAmountLabel.textAlignment = .left
            depositCompleteAmountLabel.text = formatToDollarAmount(amount: depositAmount)
            depositCompleteAmountLabel.textColor = .secondaryLabel
            
            depositCompleteVStack.setCustomSpacing(20, after: depositCompleteAmountLabel)
            depositCompleteVStack.addArrangedSubview(depositCompleteDepositTitle)
            depositCompleteDepositTitle.widthAnchor.constraint(equalTo: mainVStack.widthAnchor).isActive = true
            depositCompleteDepositTitle.textAlignment = .left
            depositCompleteDepositTitle.text = NSLocalizedString("Deposit ID", comment: "Header for a row that displays the deposit ID of a deposited check.")
            depositCompleteDepositTitle.font = .systemFont(ofSize: 17, weight: .medium)
            depositCompleteVStack.addArrangedSubview(depositCompleteDepositID)
            depositCompleteDepositID.widthAnchor.constraint(equalTo: mainVStack.widthAnchor).isActive = true
            depositCompleteDepositID.textAlignment = .left
            depositCompleteDepositID.text = depositID
            depositCompleteDepositID.textColor = .secondaryLabel
            
            let spacer = UIView()
            mainVStack.addArrangedSubview(spacer)
            setUpActionOptions(for: depositStatus)
            
        case let .editsRequired(details):
            statusHeaderView.statusImage = UIImage(named: "EditsRequired")
            statusHeaderView.statusTitle = NSLocalizedString("Edits required", comment: "Header title on the check status screen when the check cannot be confirmed and has several edits necessary before moving forward.")
            
            mainVStack.addArrangedSubview(depositContextLabel)
            depositContextLabel.text = NSLocalizedString("Your deposit requires some changes in order to be submitted. Please address the following issues", comment: "Context for a check deposit needing edits.")
            depositContextLabel.lineBreakMode = .byWordWrapping
            depositContextLabel.numberOfLines = 0
            depositContextLabel.textColor = .secondaryLabel
            
            mainVStack.setCustomSpacing(35, after: depositContextLabel)
            
            addScrollViewWithDetails(details: details)
            
            let spacer = UIView()
            mainVStack.addArrangedSubview(spacer)
            setUpActionOptions(for: depositStatus)
        }
    }

    private func addScrollViewWithDetails(details: [String]?) {
        var imageColor = UIColor()
        var imageName = ""
        
        switch depositStatus {
        case .confirmDetails:
            imageColor = UIColor.systemGreen
            imageName = "checkmark"
            
        case .editsRequired:
            imageColor = UIColor.systemOrange
            imageName = "exclamationmark.triangle.fill"
            
        case .confirmDeposit, .depositComplete: break
        }
        
        let details = createDetailsForDeposit(
            imageName: imageName,
            imageColor: imageColor,
            messages: details ?? []
        )
        
        detailsScrollView.translatesAutoresizingMaskIntoConstraints = false
        detailsScrollView.isScrollEnabled = true
        mainVStack.addArrangedSubview(detailsScrollView)
        detailsScrollView.addSubview(details)
        
        NSLayoutConstraint.activate([
            detailsScrollView.widthAnchor.constraint(equalTo: mainVStack.widthAnchor),
            details.widthAnchor.constraint(equalTo: detailsScrollView.frameLayoutGuide.widthAnchor)
        ])
        details.pinEdges(to: detailsScrollView.contentLayoutGuide)
        mainVStack.setCustomSpacing(35, after: detailsScrollView)
    }
    
    private func addSummaryText(amount: Int, accountID: String) {
        mainVStack.addArrangedSubview(depositAmountAndAccountInfoLabel)
        depositAmountAndAccountInfoLabel.text = String.localizedStringWithFormat(NSLocalizedString("%@ will be deposited into your account ending in %@.", comment: "Text confirming the amount and account that will be deposited for a user."), formatToDollarAmount(amount: depositAmount), lastFourDigitsOfAccount(accountID: accountId))
        depositAmountAndAccountInfoLabel.font = .systemFont(ofSize: 16, weight: .medium)
        depositAmountAndAccountInfoLabel.numberOfLines = 0
        depositAmountAndAccountInfoLabel.lineBreakMode = .byWordWrapping
    }
    
    private func createDetailsForDeposit(imageName: String, imageColor: UIColor, messages: [String]) -> UIView {
        let infoStackView = UIStackView()
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.axis = .vertical
        infoStackView.spacing = 15
        
        for message in messages {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.alignment = .top
            hStack.spacing = 5
            infoStackView.addArrangedSubview(hStack)
            
            let infoImageView = UIImageView()
            NSLayoutConstraint.activate([
                infoImageView.heightAnchor.constraint(equalToConstant: 25),
                infoImageView.widthAnchor.constraint(equalToConstant: 25)
            ])
            infoImageView.image = UIImage(systemName: imageName)
            infoImageView.tintColor = imageColor
            infoImageView.contentMode = .scaleAspectFit
            infoImageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            hStack.addArrangedSubview(infoImageView)
            
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.lineBreakMode = .byWordWrapping
            messageLabel.numberOfLines = 0
            messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
            hStack.addArrangedSubview(messageLabel)
            
            infoStackView.addArrangedSubview(hStack)
        }
        return infoStackView
    }
    
    private func setUpActionOptions(for status: DepositStatus) {
        mainVStack.addArrangedSubview(nextActionOptionsVStack)
        nextActionOptionsVStack.axis = .vertical
        nextActionOptionsVStack.alignment = .center
        nextActionOptionsVStack.spacing = 10
        nextActionOptionsVStack.addArrangedSubview(finalConfirmationButton)
        finalConfirmationButton.isEnabled = true
        
        nextActionOptionsVStack.addArrangedSubview(secondaryActionButton)
        secondaryActionButton.setTitleColor(.gray, for: .normal)
        secondaryActionButton.titleLabel?.font = .systemFont(ofSize: 15)
        NSLayoutConstraint.activate([
            secondaryActionButton.widthAnchor.constraint(equalTo: mainVStack.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            finalConfirmationButton.widthAnchor.constraint(equalTo: mainVStack.widthAnchor)
        ])
        
        switch status {
        case .editsRequired:
            finalConfirmationButton.setTitle(NSLocalizedString("Edit deposit", comment: "The title of a button that will allow editing the check deposit"), for: .normal)
            finalConfirmationButton.addTarget(self, action: #selector(dismissToPreviousView), for: .primaryActionTriggered)
            
            secondaryActionButton.setTitle(NSLocalizedString("Start over", comment: "The title of a button that will allow starting a new check deposit"), for: .normal)
            secondaryActionButton.addTarget(self, action: #selector(startDepositOver), for: .primaryActionTriggered)
        case .confirmDetails, .confirmDeposit:
            finalConfirmationButton.setTitle(NSLocalizedString("Confirm deposit", comment: "The title of a button that will trigger confirmation of the check deposit"), for: .normal)
            finalConfirmationButton.addTarget(self, action: #selector(confirmButtonSelected), for: .primaryActionTriggered)
            
            secondaryActionButton.setTitle(NSLocalizedString("Edit deposit", comment: "The title of a button that will allow editing the check deposit"), for: .normal)
            secondaryActionButton.addTarget(self, action: #selector(dismissToPreviousView), for: .primaryActionTriggered)
        case .depositComplete:
            finalConfirmationButton.setTitle(NSLocalizedString("Start a new deposit", comment: "The title of a button that will allow starting a new check deposit"), for: .normal)
            finalConfirmationButton.addTarget(self, action: #selector(startDepositOver), for: .primaryActionTriggered)
            
            secondaryActionButton.isHidden = true
        }
    }
    
    private func formatToDollarAmount(amount: Int) -> String {
        let newAmount = Double(amount)
        let decimal = newAmount / 100
        return DepositStatusViewController.currencyFormatter.string(from: NSNumber(value: decimal)) ?? ""
    }
    
    private func lastFourDigitsOfAccount(accountID: String) -> String {
        return String(accountID.suffix(4))
    }
    
    // MARK: Button Actions
    
    @objc private func dismissToPreviousView() {
        delegate?.popToRoot()
    }
    
    @objc private func startDepositOver() {
        delegate?.startOver()
    }

    @objc private func confirmButtonSelected() {
        Task {
            await submitDepositInfo()
        }
    }
    
    // MARK: Network Requests
    
    private func submitDepositInfo() async {
        InteractionBlockingProgressWindow.show()

        do {
            let confirmedDeposit = try await confirmedDeposit(depositID: depositID)
            
            switch confirmedDeposit.status {
            case .processing:
                let depositCompleteViewController = DepositStatusViewController(depositStatus: .depositComplete, depositID: depositID, depositAmount: depositAmount, accountId: accountId, delegate: delegate)
                navigationController?.pushViewController(depositCompleteViewController, animated: true)
            case .requiresConfirmation, .requiresAction:
                assertionFailure("Unexpected deposit status returned from API")
            }
        } catch let error {
            showErrorAlert(for: error)
        }
        
        InteractionBlockingProgressWindow.hide()
    }
    
    private func confirmedDeposit(depositID: String) async throws -> FullCheckDepositResponse {
        let confirmDepositRequest = ConfirmDepositRequest(depositID: depositID)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try await networkController.send(confirmDepositRequest, decoder: decoder)
    }
}
