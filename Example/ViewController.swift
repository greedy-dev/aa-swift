//
//  ViewController.swift
//  Example
//
//  Created by Andrei Ashikhmin on 18/01/2024.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private var cancellableBag = Set<AnyCancellable>()
    private let viewModel = MainViewModel()
    
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var stepTxt: UILabel!
    @IBOutlet var progress: UIActivityIndicatorView!
    @IBOutlet var mintBtn: UIButton!
    @IBOutlet var logoutBtn: UIButton!
    @IBOutlet var linkTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$uiState
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                            
                self.progress.isHidden = state.step != .key && state.step != .address
                self.loginBtn.isHidden = state.step != .notStarted
                self.logoutBtn.isHidden = state.step < .ready
                self.mintBtn.isHidden = state.step != .ready
                self.stepTxt.isHidden = state.step == .notStarted
                            
                if state.step == .error {
                    self.stepTxt.text = state.error
                    self.stepTxt.textColor = .red
                } else {
                    self.stepTxt.text = self.textForStep(state.step, address: state.address, balance: state.balance)
                    self.stepTxt.textColor = .black
                }
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.copyAddressToClipboard))
                self.stepTxt.addGestureRecognizer(tapGesture)
                self.stepTxt.isUserInteractionEnabled = true
                self.setupExplorerLink(state.explorerLink)
            }
            .store(in: &cancellableBag)
    }
    
    @IBAction
    func mint() {
        viewModel.mint()
    }
    
    @IBAction
    func login() {
        viewModel.login()
    }
    
    @IBAction
    func logout() {
        viewModel.logout()
    }
    
    private func textForStep(_ step: Step, address: String?, balance: String?) -> String {
        switch step {
        case .key:
            return "Fetching your key..."
        case .address:
            return "Fetching your smart contract account address..."
        case .ready:
            return "Your account is ready: \(address ?? "") (Sepolia network)"
        case .minting:
            return "Minting Alchemy tokens..."
        case .confirming:
            return "Confirming transaction..."
        case .done:
            return "Done! Alchemy Token balance: \(balance ?? "")"
        default:
            return ""
        }
    }
    
    @objc private func copyAddressToClipboard() {
        guard let address = viewModel.uiState.address else { return }
        UIPasteboard.general.string = address
        showCopyToClipboardToast()
    }
    
    private func setupExplorerLink(_ link: String?) {
        guard let link = link, !link.isEmpty else {
            linkTxt.isHidden = true
            return
        }
        
        linkTxt.isHidden = false
        linkTxt.text = link
        linkTxt.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openExplorerLink))
        linkTxt.addGestureRecognizer(tapGesture)
    }

    @objc private func openExplorerLink() {
        guard let urlString = viewModel.uiState.explorerLink, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

extension ViewController {
    func showCopyToClipboardToast() {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.text = " Copied to clipboard "
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            toastLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 2.0, options: [], animations: {
                toastLabel.alpha = 0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        }
    }
}
