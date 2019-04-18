//
//  ALUCoordinator.swift
//  CPUSim
//
//  Created by Jacob Morgan Hope on 3/31/19.
//  Copyright © 2019 Jacob M. Hope. All rights reserved.
//

import Foundation
import UIKit

protocol ALUCoordinatorDelegate: class {
    func aluCoordinatorDidRequestCancel(aluCoordinator: ALUCoordinator)
    func aluCoordinator(aluCoordinator: ALUCoordinator, payload: ALUCoordinatorPayload)
}

class ALUCoordinatorPayload {
    // Data passed through the view controllers
}

class ALUCoordinator: RootViewCoordinator {
    
    // MARK: Properties
    
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return self.navigationController
    }
    weak var delegate: ALUCoordinatorDelegate?
    var orderPayload: ALUCoordinatorPayload?
    private lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        return navigationController
    }()
    
    private let drawingService: Drawing
    private let fetchStateService: State
    //private var fetchViewController: FetchViewController?
    
    // MARK: Init
    
    init(drawingService: Drawing,
         fetchStateService: State) {
        self.drawingService = drawingService
        self.fetchStateService = fetchStateService
    }
    
    // MARK: Functions
    
    func start() {
        self.showFetchViewController()
    }
    
    func showFetchViewController() {
        let fetchViewController = FetchViewController()
        fetchViewController.delegate = self
        self.navigationController.viewControllers = [fetchViewController]
        //self.fetchViewController = fetchViewController
    }
    
    func showDecodeViewController() {
         let decodeViewController = DecodeViewController()
         decodeViewController.delegate = self
         self.navigationController.pushViewController(decodeViewController, animated: true)
    }
     
    func showExecuteViewController() {
         let executeViewController = ExecuteViewController()
         executeViewController.delegate = self
         self.navigationController.pushViewController(executeViewController, animated: true)
    }
     
    func showMemoryAccessViewController() {
         let memoryAccessViewController = MemoryAccessViewController()
         memoryAccessViewController.delegate = self
         self.navigationController.pushViewController(memoryAccessViewController, animated: true)
    }
     
    func showWriteBackViewController() {
         let writeBackViewController = WriteBackViewController()
         writeBackViewController.delegate = self
         self.navigationController.pushViewController(writeBackViewController, animated: true)
    }
}


// MARK: FetchViewControllerDelegate

extension ALUCoordinator: FetchViewControllerDelegate {
    
    func fetchViewControllerOnTouchesBegan(_ fetchViewController: FetchViewController, _ touches: Set<UITouch>, with event: UIEvent?) {
        drawingService.clearDrawing(
            imageView: fetchViewController.drawingImageView)
        
        fetchStateService.handleTouchesBegan(
            touches,
            with: event,
            touchPoints: fetchViewController.touchPoints,
            view: fetchViewController.drawingImageView)
    }
    
    func fetchViewControllerOnTouchesMoved(_ fetchViewController: FetchViewController, _ touches: Set<UITouch>, with event: UIEvent?) {
        // todo: pass in only drawingImageView
        fetchStateService.handleTouchesMoved(
            touches,
            with: event,
            imageView: fetchViewController.drawingImageView,
            view: fetchViewController.drawingImageView,
            withDrawing: drawingService,
            touchPoints: fetchViewController.touchPoints,
            lines: fetchViewController.lines)
    }
    
    func fetchViewControllerOnTouchesEnded(_ fetchViewController: FetchViewController) {
        fetchStateService.resetState()
    }
    
    func fetchViewControllerOnTouchesCancelled(_ fetchViewController: FetchViewController) {
        drawingService.resumeTouchInput()
        fetchStateService.resetState()
    }
    
    func fetchViewControllerClearDrawing(_ fetchViewController: FetchViewController) {
        drawingService.clearDrawing(imageView: fetchViewController.drawingImageView)
    }
    
    func fetchViewControllerSetup(_ fetchViewController: FetchViewController) {
        fetchViewController.touchPoints.forEach { touchPoint in
            touchPoint.setupWith(
                DotModel(
                    x: -4.75,
                    y: -4.75,
                    radius: 10.0))
        }
        
        for (_, v) in fetchViewController.lines {
            v.forEach { line in
                line.setup()
            }
        }
    }
    
    func fetchViewControllerDidSwipeLeft(_ fetchViewController: FetchViewController) {
        if (!fetchStateService.isDrawing) {
            self.navigationController.popViewController(animated: true)
        }
    }
    
    func fetchViewControllerDidSwipeRight(_ fetchViewController: FetchViewController) {
        if (!fetchStateService.isDrawing) {
            self.showDecodeViewController()
        }
    }
    
    func fetchViewControllerDidTapClose(_ fetchViewController: FetchViewController) {
        self.delegate?.aluCoordinatorDidRequestCancel(aluCoordinator: self)
    }
    
    func fetchViewController(_ fetchViewController: FetchViewController) {
        //self.showDecodeViewController()
    }
}

// MARK: DecodeViewControllerDelegate

extension ALUCoordinator: DecodeViewControllerDelegate {
    func decodeViewControllerDidSwipeLeft(_ decodeViewController: DecodeViewController) {
        self.navigationController.popViewController(animated: true)

//        guard let tvc = self.navigationController.topViewController else {
//            return
//        }
//        switch tvc.nibName {
//        case "FetchView":
//            // Reset pulsation animation
//            let fvc: FetchViewController = tvc as! FetchViewController
//            fvc.touchPoints.forEach { tp in
//                for (k,v) in fetchStateService.correctnessMap {
//                    if (k == "ifMuxToPc" && v == false) {
//                        if (tp.name == "ifMuxToPcStart") {
//                            tp.setupWith(
//                                DotModel(
//                                    x: -4.75,
//                                    y: -4.75,
//                                    radius: 10.0))
//                        }
//                        if (tp.name == "ifMuxToPcEnd") {
//                            tp.setupWith(
//                                DotModel(
//                                    x: -4.75,
//                                    y: -4.75,
//                                    radius: 10.0))
//                        }
//                    }
//                }
//            }
//            break;
//        default:
//            break;
//        }
    }
    
    func decodeViewControllerDidSwipeRight(_ decodeViewController: DecodeViewController) {
        self.showExecuteViewController()
    }
    
    func decodeViewController(_ decodeViewController: DecodeViewController) {
        
    }
    
}

// MARK: ExecuteViewControllerDelegate

extension ALUCoordinator: ExecuteViewControllerDelegate {
    func executeViewControllerDidSwipeLeft(_ executeViewController: ExecuteViewController) {
        self.navigationController.popViewController(animated: true)
    }
    
    func executeViewControllerDidSwipeRight(_ executeViewController: ExecuteViewController) {
        self.showMemoryAccessViewController()
    }
    
    
    func executeViewController(_ executeViewController: ExecuteViewController) {
        
    }
    
}

// MARK: MemoryAccessViewControllerDelegate

extension ALUCoordinator: MemoryAccessViewControllerDelegate {
    func memoryAccessViewControllerDidSwipeLeft(_ memoryAccessViewController: MemoryAccessViewController) {
        self.navigationController.popViewController(animated: true)
    }
    
    func memoryAccessViewControllerDidSwipeRight(_ memoryAccessViewController: MemoryAccessViewController) {
        self.showWriteBackViewController()
    }
    
   
    func memoryAccessViewController(_ memoryAccessViewController: MemoryAccessViewController) {
        
    }
    
}

// MARK: WriteBackViewControllerDelegate

extension ALUCoordinator: WriteBackViewControllerDelegate {
    func writeBackViewControllerDidSwipeLeft(_ writeBackViewController: WriteBackViewController) {
        self.navigationController.popViewController(animated: true)
    }
    
    func writeBackViewControllerDidSwipeRight(_ writeBackViewController: WriteBackViewController) {
    }
    
    func writeBackViewControllerDidTapDone(_ writeBackViewController: WriteBackViewController) {
    }
    
    func writeBackViewController(_ writeBackViewController: WriteBackViewController) {
        
    }
}
