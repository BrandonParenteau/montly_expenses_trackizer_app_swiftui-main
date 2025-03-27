//
//  LinkController.swift
//  Trackizer
//
//  Created by Brandon Parenteau on 2025-02-15.
//

import LinkKit
import SwiftUI

/// A SwiftUI wrapper for Plaid Link that bridges UIKit implementation
struct LinkController: UIViewControllerRepresentable {
    // MARK: - Properties
    private let handler: Handler
    
    // MARK: - Initialization
    init(handler: Handler) {
        self.handler = handler
    }
    
    // MARK: - Coordinator
    final class Coordinator: NSObject {
        private let parent: LinkController
        private let handler: Handler
        
        fileprivate init(parent: LinkController, handler: Handler) {
            self.parent = parent
            self.handler = handler
        }
        
        fileprivate func present(_ handler: Handler, in viewController: UIViewController) {
            handler.open(presentUsing: .custom({ linkViewController in
                // Add as child view controller
                viewController.addChild(linkViewController)
                
                // Configure view hierarchy
                viewController.view.addSubview(linkViewController.view)
                linkViewController.view.translatesAutoresizingMaskIntoConstraints = false
                
                // Set initial frame
                linkViewController.view.frame = viewController.view.bounds
                
                // Setup constraints
                NSLayoutConstraint.activate([
                    linkViewController.view.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
                    linkViewController.view.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
                    linkViewController.view.widthAnchor.constraint(equalTo: viewController.view.widthAnchor),
                    linkViewController.view.heightAnchor.constraint(equalTo: viewController.view.heightAnchor)
                ])
                
                // Complete child view controller setup
                linkViewController.didMove(toParent: viewController)
            }))
        }
    }
    
    // MARK: - UIViewControllerRepresentable
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, handler: handler)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        context.coordinator.present(handler, in: viewController)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed as this is a one-time presentation
    }
}


