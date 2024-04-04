//
//  CheckDepositViewController.swift
//  RDC Testing
//
//  Created by Brian Capps on 5/17/22.
//  Copyright © 2022 Stripe. All rights reserved.
//

import UIKit
import MiSnapSDK
import Networking

/// A view controller that allows the user to collect all the necessary information for a check deposit and send it to the Stripe RDC API endpoints.
final class CheckDepositViewController: UIViewController {
    
    private enum CheckSide: String {
        case front = "CheckFront"
        case back = "CheckBack"
    }
    
    private struct CheckDepositData {
        let checkFront: UIImage
        let checkBack: UIImage
        let description: String
        let amountInCents: Int
    }
    
    private let mainVStack = UIStackView()
    private let accountsHStack = UIStackView()
    
    private let financialAccountVStack = UIStackView()
    private let financialAccountTitleLabel = UILabel()
    private let financialAccountLabel = CopyableLabel()
    private let accountsSpacerView = UIView()
    private let stripeAccountVStack = UIStackView()
    private let stripeAccountTitleLabel = UILabel()
    private let stripeAccountLabel = CopyableLabel()
    
    private let accountsToDepositSpacer = UIView()
    private let depositAccountVStack = UIStackView()
    private let depositAmountTitleLabel = UILabel()
    private let depositAmountTextField = CurrencyTextField()
    
    private let depositDescriptionTitleLabel = UILabel()
    private let depositDescriptionTextField = DescriptionTextField()

    private let checkImageVStack = UIStackView()
    private let checkFrontLabel = UILabel()
    private let checkFrontImageButton = CheckCaptureButton()
    private let checkBackLabel = UILabel()
    private let checkBackImageButton = CheckCaptureButton()
    
    private let actionOptionsVStack = UIStackView()
    private let makeDepositButton = StyledPrimaryActionButton()
    private let resetDepositButton = UIButton(type: .system)
    
    private let networkController = NetworkController()
    private var currentCheckOrientation: CheckSide?
    
    private var checkFront: UIImage? {
        didSet {
            updateCheckImages()
        }
    }
    
    private var checkBack: UIImage? {
        didSet {
            updateCheckImages()
        }
    }
    
    private var checkDepositData: CheckDepositData? {
        guard let checkFront = checkFront, let checkBack = checkBack, let description = depositDescriptionTextField.text, let amountInCents = depositAmountTextField.cents, amountInCents > 0 else {
            return nil
        }
        
        return CheckDepositData(checkFront: checkFront, checkBack: checkBack, description: description.isEmpty ? "Test check" : description, amountInCents: amountInCents)
    }
    
    private var canInitiateDeposit: Bool {
        return checkDepositData != nil
    }
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    // MARK: - UIViewController
        
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Check Deposit", comment: "The title for the check deposit screen")
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainVStack)
        mainVStack.translatesAutoresizingMaskIntoConstraints = false
        mainVStack.axis = .vertical
        
        NSLayoutConstraint.activate([
            mainVStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainVStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mainVStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 17),
            mainVStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        
        setUpAccountsLabels()
        setUpAmountTextField()
        setUpCheckImageButtons()
        setUpNextActionButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Resign the textfield as the first responder when tapping anywhere outside of it.
        depositAmountTextField.resignFirstResponder()
    }
    
    // MARK: - CheckDepositViewController
    
    // MARK: View Setup
    
    private func setUpAccountsLabels() {
        mainVStack.addArrangedSubview(accountsHStack)
        accountsHStack.axis = .horizontal
        accountsHStack.spacing = 10
        
        financialAccountVStack.axis = .vertical
        financialAccountVStack.alignment = .leading
        financialAccountVStack.spacing = 4
        accountsHStack.addArrangedSubview(financialAccountVStack)
        
        financialAccountTitleLabel.text = NSLocalizedString("Financial Account", comment: "Financial Account Label")
        financialAccountTitleLabel.font = .systemFont(ofSize: 18)
        financialAccountVStack.addArrangedSubview(financialAccountTitleLabel)
        
        financialAccountLabel.text = NSLocalizedString(K.APIInfo.financialAccount, comment: "Financial Account ID")
        financialAccountLabel.font = .systemFont(ofSize: 14)
        financialAccountLabel.textColor = .secondaryLabel
        financialAccountLabel.adjustsFontSizeToFitWidth = true
        financialAccountLabel.minimumScaleFactor = 0.7
        financialAccountVStack.addArrangedSubview(financialAccountLabel)
        
        accountsSpacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        accountsHStack.addArrangedSubview(accountsSpacerView)
        
        stripeAccountVStack.axis = .vertical
        stripeAccountVStack.alignment = .leading
        stripeAccountVStack.spacing = 4
        accountsHStack.addArrangedSubview(stripeAccountVStack)
        stripeAccountVStack.translatesAutoresizingMaskIntoConstraints = false
        
        stripeAccountTitleLabel.text = NSLocalizedString("Stripe Account", comment: "Stripe Account Label")
        stripeAccountTitleLabel.font = .systemFont(ofSize: 18)
        stripeAccountVStack.addArrangedSubview(stripeAccountTitleLabel)
        stripeAccountTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stripeAccountLabel.text = NSLocalizedString(K.APIInfo.account, comment: "Stripe Account ID")
        stripeAccountLabel.font = .systemFont(ofSize: 14)
        stripeAccountLabel.textColor = .secondaryLabel
        stripeAccountLabel.adjustsFontSizeToFitWidth = true
        stripeAccountLabel.minimumScaleFactor = 0.7
        stripeAccountVStack.addArrangedSubview(stripeAccountLabel)
        stripeAccountLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpAmountTextField() {
        mainVStack.addArrangedSubview(accountsToDepositSpacer)
        accountsToDepositSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        accountsToDepositSpacer.translatesAutoresizingMaskIntoConstraints = false
        
        mainVStack.addArrangedSubview(depositAccountVStack)
        depositAccountVStack.translatesAutoresizingMaskIntoConstraints = false
        depositAccountVStack.axis = .vertical
        depositAccountVStack.alignment = .center
        depositAccountVStack.spacing = 4
        
        depositAmountTitleLabel.text = NSLocalizedString("Amount", comment: "Deposit Amount")
        depositAmountTitleLabel.textAlignment = .left
        depositAmountTitleLabel.font = .systemFont(ofSize: 14)
        depositAmountTitleLabel.textColor = .darkGray
        depositAccountVStack.addArrangedSubview(depositAmountTitleLabel)
        depositAmountTitleLabel.widthAnchor.constraint(equalTo: mainVStack.widthAnchor).isActive = true
        
        depositAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        depositAccountVStack.addArrangedSubview(depositAmountTextField)
        depositAmountTextField.layer.borderWidth = 1
        depositAmountTextField.layer.borderColor = UIColor.darkGray.cgColor
        depositAmountTextField.layer.cornerRadius = 4
        depositAmountTextField.font = .systemFont(ofSize: 14)
        depositAmountTextField.addTarget(self, action: #selector(amountTextFieldChanged), for: .editingChanged)
        
        depositAccountVStack.setCustomSpacing(15, after: depositAmountTextField)

        depositDescriptionTitleLabel.text = NSLocalizedString("Description", comment: "Deposit description")
        depositDescriptionTitleLabel.textAlignment = .left
        depositDescriptionTitleLabel.font = .systemFont(ofSize: 14)
        depositDescriptionTitleLabel.textColor = .darkGray
        depositAccountVStack.addArrangedSubview(depositDescriptionTitleLabel)
        depositDescriptionTitleLabel.widthAnchor.constraint(equalTo: mainVStack.widthAnchor).isActive = true

        depositDescriptionTextField.translatesAutoresizingMaskIntoConstraints = false
        depositAccountVStack.addArrangedSubview(depositDescriptionTextField)
        depositDescriptionTextField.layer.borderWidth = 1
        depositDescriptionTextField.layer.borderColor = UIColor.darkGray.cgColor
        depositDescriptionTextField.layer.cornerRadius = 4
        depositDescriptionTextField.font = .systemFont(ofSize: 14)

        NSLayoutConstraint.activate([
            depositAmountTextField.widthAnchor.constraint(equalTo: mainVStack.widthAnchor),
            depositAmountTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

        NSLayoutConstraint.activate([
            depositDescriptionTextField.widthAnchor.constraint(equalTo: mainVStack.widthAnchor),
            depositDescriptionTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

        mainVStack.setCustomSpacing(35, after: depositAccountVStack)
    }
    
    private func setUpCheckImageButtons() {
        mainVStack.addArrangedSubview(checkImageVStack)
        checkImageVStack.axis = .vertical
        checkImageVStack.alignment = .center
        checkImageVStack.spacing = 4
        
        checkImageVStack.addArrangedSubview(checkFrontLabel)
        checkFrontLabel.text = NSLocalizedString("Check front", comment: "Check image front label")
        checkFrontLabel.textAlignment = .left
        checkFrontLabel.font = .systemFont(ofSize: 12)
        checkFrontLabel.textColor = .darkGray
        checkFrontLabel.widthAnchor.constraint(equalTo: mainVStack.widthAnchor).isActive = true
        
        checkImageVStack.addArrangedSubview(checkFrontImageButton)
        checkFrontImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkFrontImageButton.heightAnchor.constraint(equalToConstant: 156),
            checkFrontImageButton.widthAnchor.constraint(equalTo: mainVStack.widthAnchor)
        ])
        
        checkFrontImageButton.onTap = { [weak self] in
            self?.presentCheckFrontScanner()
        }
        
        checkImageVStack.setCustomSpacing(20, after: checkFrontImageButton)
        
        checkImageVStack.addArrangedSubview(checkBackLabel)
        checkBackLabel.text = NSLocalizedString("Check back", comment: "Check image back label")
        checkBackLabel.textAlignment = .left
        checkBackLabel.font = .systemFont(ofSize: 12)
        checkBackLabel.textColor = .darkGray
        checkBackLabel.widthAnchor.constraint(equalTo: mainVStack.widthAnchor).isActive = true
        
        checkImageVStack.addArrangedSubview(checkBackImageButton)
        checkBackImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkBackImageButton.heightAnchor.constraint(equalToConstant: 156),
            checkBackImageButton.widthAnchor.constraint(equalTo: mainVStack.widthAnchor)
        ])
        
        checkBackImageButton.onTap = { [weak self] in
            self?.presentCheckBackScanner()
        }
        
        updateCheckImages()
        
        mainVStack.setCustomSpacing(38, after: checkImageVStack)
    }
    
    private func setUpNextActionButtons() {
        mainVStack.addArrangedSubview(actionOptionsVStack)
        actionOptionsVStack.axis = .vertical
        actionOptionsVStack.alignment = .center
        actionOptionsVStack.spacing = 5
        
        actionOptionsVStack.addArrangedSubview(makeDepositButton)
        makeDepositButton.isEnabled = false
        makeDepositButton.setTitle(NSLocalizedString("Make deposit", comment: "Make Deposit Button"), for: .normal)
        NSLayoutConstraint.activate([
            makeDepositButton.widthAnchor.constraint(equalTo: mainVStack.widthAnchor)
        ])
        makeDepositButton.addTarget(self, action: #selector(submitDepositInfo), for: .primaryActionTriggered)
        
        actionOptionsVStack.addArrangedSubview(resetDepositButton)
        resetDepositButton.setTitle(NSLocalizedString("Reset", comment: "Reset Deposit Button"), for: .normal)
        resetDepositButton.setTitleColor(.gray, for: .normal)
        resetDepositButton.titleLabel?.font = .systemFont(ofSize: 14)
        NSLayoutConstraint.activate([
            resetDepositButton.widthAnchor.constraint(equalTo: mainVStack.widthAnchor)
        ])
        resetDepositButton.addTarget(self, action: #selector(resetDepositData), for: .primaryActionTriggered)
    }
    
    private func updateCheckImages() {
        checkFrontImageButton.viewModel = .init(image: checkFront)
        checkBackImageButton.viewModel = .init(image: checkBack)
        
        updateMakeDepositButtonState()
    }

    private func updateMakeDepositButtonState() {
        makeDepositButton.isEnabled = canInitiateDeposit
    }
    
    // MARK: MiSnap Presentation
        
    private func presentUXForCheckScanning(for checkSide: CheckSide) {
        let storyboard = UIStoryboard(name: "MiSnapUX2", bundle: nil)
        guard let snapView = storyboard.instantiateViewController(withIdentifier: "MiSnapSDKViewControllerUX2") as? MiSnapSDKViewControllerUX2 else {
            fatalError("Can't produce MiSnapSDKViewControllerUX2 from storyboard.")
        }
        
        let achDefaultParameters = MiSnapSDKViewController.defaultParametersForACH() as? [AnyHashable: String]
        let viewParameters: [AnyHashable: String]?

        switch checkSide {
        case .front:
            viewParameters = MiSnapSDKViewController.defaultParametersForCheckFront() as? [AnyHashable: String]
        case .back:
            viewParameters = MiSnapSDKViewController.defaultParametersForCheckBack() as? [AnyHashable: String]
        }
        
        guard let achDefaultParameters = achDefaultParameters, let viewParameters = viewParameters else {
            assertionFailure("Could not convert dictionary from MiSnap to Swift dictionary")
            return
        }
        
        let miSnapParameters = achDefaultParameters
            .merging(viewParameters) { (_, new) in new }
                
        snapView.modalPresentationStyle = .fullScreen
        snapView.modalTransitionStyle = .crossDissolve
        snapView.setupMiSnap(withParams: miSnapParameters)
        snapView.delegate = self
        present(snapView, animated: true)
    }
    
    // MARK: Control Actions
    
    @objc private func amountTextFieldChanged() {
        updateMakeDepositButtonState()
    }
    
    @objc private func presentCheckFrontScanner() {
        currentCheckOrientation = .front
        presentUXForCheckScanning(for: .front)
    }
    
    @objc private func presentCheckBackScanner() {
        currentCheckOrientation = .back
        presentUXForCheckScanning(for: .back)
    }
    
    @objc private func submitDepositInfo() {
        Task {
            await createAndUpdateDeposit()
        }
    }
    
    @objc private func resetDepositData() {
        print("Resetting all data")
        checkFront = nil
        checkBack = nil
        depositAmountTextField.text = nil
    }
    
    // MARK: Network Requests
        
    private func createAndUpdateDeposit() async {
        guard let checkUploadData = checkDepositData else {
            assertionFailure("Not all check upload data was present when attempting to make requests.")
            return
        }
        
        InteractionBlockingProgressWindow.show()
        
        do {
            let depositID = try await createCheckDeposit()
            print("Stripe API Response: Check Deposit ID: \(depositID)")
            
            async let frontImageID = await sendImageToStripe(checkSide: .front, image: checkUploadData.checkFront)
            async let backImageID = await sendImageToStripe(checkSide: .back, image: checkUploadData.checkBack)
            try await print("Stripe API Response: Front Image File ID: \(frontImageID)")
            try await print("Stripe API Response: Back Image File ID: \(backImageID)")

            let updatedDeposit = try await updateCheckDeposit(depositID: depositID, description: checkUploadData.description, amount: checkUploadData.amountInCents, checkFrontID: frontImageID, checkBackID: backImageID)
            print("Stripe API Response: Check Deposit Updated: \(updatedDeposit)")
            
            let depositStatus: DepositStatusViewController.DepositStatus
            
            switch updatedDeposit.status {
            case .requiresConfirmation:
                let confirmableRiskFactorDetails = updatedDeposit.confirmableRiskFactors?.map(\.description) ?? []
                depositStatus = confirmableRiskFactorDetails.isEmpty ? .confirmDeposit : .confirmDetails(details: confirmableRiskFactorDetails)
            case .requiresAction:
                let riskMitigationSuggestions = updatedDeposit.nextAction?.riskFactors?.map { $0.description } ?? []
                depositStatus = .editsRequired(details: riskMitigationSuggestions)
            case .processing:
                fatalError("Invalid state for deposit at this time.")
            }
            
            let depositStatusViewController = DepositStatusViewController(depositStatus: depositStatus, depositID: depositID, depositAmount: checkUploadData.amountInCents, accountId: updatedDeposit.financialAccount, delegate: self)
            navigationController?.pushViewController(depositStatusViewController, animated: true)
        } catch let error {
            showErrorAlert(for: error)
        }
        
        InteractionBlockingProgressWindow.hide()
    }
    
    private func requestAccountFeatures() async throws -> AccountFeaturesResponse {
        print("Stripe API Call: Requesting account features")
        let request = FeaturesPerAccountRequest()
        return try await networkController.send(request, decoder: decoder)
    }
    
    private func createCheckDeposit() async throws -> String {
        print("Stripe API Call: Creating check deposit")
        let request = CreateCheckDepositRequest()
        let deposit: CreateCheckDepositResponse = try await networkController.send(request, decoder: decoder)
        return deposit.id
    }
    
    private func sendImageToStripe(checkSide: CheckSide, image: UIImage) async throws -> String {
        print("Stripe API Call: Sending image to Stripe servers")
        let checkImageUploadRequest = UploadImagesRequest(checkImageName: checkSide.rawValue, checkImage: image)
        let imageUploadResponse: CheckImageUploadResponse = try await networkController.send(checkImageUploadRequest, decoder: decoder)
        return imageUploadResponse.id
    }
    
    private func updateCheckDeposit(depositID: String, description: String, amount: Int, checkFrontID: String, checkBackID: String) async throws -> FullCheckDepositResponse {
        print("Stripe API Call: Updating check deposit with image IDs")
        let checkDetails = CheckDetails(description: description, amount: amount, currency: "usd", images: CheckImagesModel(front: checkFrontID, back: checkBackID))
        let updateCheckRequest = CheckDetailsUpdateRequest(checkDespositID: depositID, checkDetails: checkDetails)
        return try await networkController.send(updateCheckRequest, decoder: decoder)
    }
}

extension CheckDepositViewController: DepositStatusNavigator {
    
    // MARK: - DepositStatusNavigator

    func popToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func startOver() {
        resetDepositData()
        popToRoot()
    }
}

extension CheckDepositViewController: MiSnapViewControllerDelegate {
    
    // MARK: - MiSnapViewControllerDelegate
    
    func miSnapFinishedReturningEncodedImage(_ encodedImage: String?, originalImage: UIImage?, andResults results: [AnyHashable: Any]?) {
        switch currentCheckOrientation {
        case .front:
            checkFront = originalImage
        case .back:
            checkBack = originalImage
        case .none:
            assertionFailure("Unexpectedly found nil for `currentCheckOrientation`")
        }
    }
}
