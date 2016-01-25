//
//  AircraftImageView.swift
//  PlaneInfo
//
//  Created by Jeffrey Sulton on 1/24/16.
//  Copyright © 2016 notluS. All rights reserved.
//

import Cocoa

class AircraftImageView: NSImageView, NSDraggingSource {

    var delegate: UpdateImage?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes(NSImage.imageTypes())
    }
    
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        switch context {
        case .OutsideApplication: return .Copy
        case .WithinApplication: return .None
        }
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        NSLog("draggingEntered")
        if (NSImage.canInitWithPasteboard(sender.draggingPasteboard())) {
            highlighted = true
            
            setNeedsDisplay()
            
            let sourceDragMask = sender.draggingSourceOperationMask()
            let pboard = sender.draggingPasteboard()
            
            if pboard.availableTypeFromArray([NSFilenamesPboardType]) == NSFilenamesPboardType {
                if sourceDragMask.rawValue & NSDragOperation.Copy.rawValue != 0 {
                    return NSDragOperation.Copy
                }
            }
        }
        
        return .None
    }

    override func draggingExited(sender: NSDraggingInfo?) {
        NSLog("draggingExited")
        highlighted = false
        setNeedsDisplay()
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
//        NSLog("performDragOperation, image=\(image?.description)")
        if (NSImage.canInitWithPasteboard(sender.draggingPasteboard())) {
            image = NSImage(pasteboard: sender.draggingPasteboard())
            delegate?.updateImage(image)
//            delegate?.dragAndDropImageViewDidDrop(self)
            setNeedsDisplay()
        }
        return true
    }
}
