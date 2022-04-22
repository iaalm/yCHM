//
//  DocPicker.swift
//  yCHM
//
//  Created by simon xu on 4/22/22.
//

import Foundation
import AppKit

struct DocPicker {
    let dialog: NSOpenPanel
    init() {
        dialog = NSOpenPanel();
        dialog.title                   = "Choose an image | Our Code World";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = false;
        dialog.allowedFileTypes        = ["chm"];
    }
    
    func display() -> String? {
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                return result!.path
            }
        }
        
        return nil
    }
}
