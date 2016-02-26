//
//  FilesViewController.swift
//  FileShareDemo
//
//  Created by Leo on 16/2/26.
//  Copyright © 2016年 Leo. All rights reserved.
//

import UIKit
import QuickLook

class FilesViewController: UITableViewController, UIDocumentInteractionControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    let docPath: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!
    
    var files = [String]()
    var docInteractionController: UIDocumentInteractionController?
    var selectedRow: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init docInteractionController
        docInteractionController = UIDocumentInteractionController.init()
        docInteractionController?.delegate = self
        
        // Add a image
        let image = UIImage.init(named: "geek")
        let imageData = UIImageJPEGRepresentation(image!, 1.0)
        let imagePath = docPath.stringByAppendingString("/geek.jpg")
        imageData?.writeToFile(imagePath, atomically: true)
        
        // Add a text
        let text = "Hello Swift!"
        let textData = text.dataUsingEncoding(NSUTF8StringEncoding)
        let textPath = docPath.stringByAppendingString("/hello.txt")
        textData?.writeToFile(textPath, atomically: true)
        
        // Get files list
        let fileManager = NSFileManager.defaultManager()
        var tempFiles = [String]()
        do {
            try tempFiles = fileManager.contentsOfDirectoryAtPath(docPath)
        } catch let error as NSError {
            print("\(error)")
        }
        files = tempFiles
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FileCell")
        
        cell?.textLabel?.text = files[indexPath.row]
        
        let filePath = docPath.stringByAppendingString("/\(files[indexPath.row])")
        let fileURL = NSURL.fileURLWithPath(filePath)
        docInteractionController?.URL = fileURL
        
        let iconCount = docInteractionController?.icons.count
        if iconCount > 0 {
            cell?.imageView?.image = docInteractionController?.icons.last
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        
        let previewController = QLPreviewController.init()
        previewController.dataSource = self
        previewController.delegate = self
        previewController.currentPreviewItemIndex = self.selectedRow!
        self.navigationController?.pushViewController(previewController, animated: true)
    }
    
    // MARK: - QLPreviewController Delegate
    
    func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        let filePath = docPath.stringByAppendingString("/\(files[selectedRow!])")
        return NSURL.fileURLWithPath(filePath)
    }
}
