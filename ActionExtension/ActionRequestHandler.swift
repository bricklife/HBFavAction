//
//  ActionRequestHandler.swift
//  ActionExtension
//
//  Created by Shinichiro Oba on 2015/04/29.
//  Copyright (c) 2015年 Shinichiro Oba. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?
    
    func beginRequestWithExtensionContext(context: NSExtensionContext) {
        // Do not call super in an Action extension with no user interface
        self.extensionContext = context
        
        var found = false
        
        // Find the item containing the results from the JavaScript preprocessing.
        for item: AnyObject in context.inputItems {
            let extItem = item as! NSExtensionItem
            if let attachments = extItem.attachments {
                for itemProvider: AnyObject in attachments {
                    if itemProvider.hasItemConformingToTypeIdentifier(String(kUTTypePropertyList)) {
                        itemProvider.loadItemForTypeIdentifier(String(kUTTypePropertyList), options: nil, completionHandler: { (item, error) in
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.doneWithResults(["dummy_key": "dummy_value"])
                            }
                        })
                        found = true
                    }
                    break
                }
            }
            if found {
                break
            }
        }
        
        if !found {
            self.doneWithResults(nil)
        }
    }
    
    func doneWithResults(resultsForJavaScriptFinalizeArg: [NSObject: AnyObject]?) {
        if let resultsForJavaScriptFinalize = resultsForJavaScriptFinalizeArg {
            // Construct an NSExtensionItem of the appropriate type to return our
            // results dictionary in.
            
            // These will be used as the arguments to the JavaScript finalize()
            // method.
            
            var resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: resultsForJavaScriptFinalize]
            
            var resultsProvider = NSItemProvider(item: resultsDictionary, typeIdentifier: String(kUTTypePropertyList))
            
            var resultsItem = NSExtensionItem()
            resultsItem.attachments = [resultsProvider]
            
            // Signal that we're complete, returning our results.
            self.extensionContext!.completeRequestReturningItems([resultsItem], completionHandler: nil)
        } else {
            // We still need to signal that we're done even if we have nothing to
            // pass back.
            self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
        }
        
        // Don't hold on to this after we finished with it.
        self.extensionContext = nil
    }

}
