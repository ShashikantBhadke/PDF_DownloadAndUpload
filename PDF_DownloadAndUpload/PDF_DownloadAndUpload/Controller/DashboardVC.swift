//
//  DashboardVC.swift
//
//
//  Created by redbytes on.
//  Copyright © redbytes. All rights reserved.
//
import UIKit
import MobileCoreServices

enum enumErrMessage: String{
    case Oops = "Oops something went. Please try again!"
}//enum

class DashboardVC: UIViewController {
    // MARK:- Outlets
    @IBOutlet private weak var btnViewFile: UIButton!
    @IBOutlet private weak var alBottonCons: NSLayoutConstraint!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK:- Variables
    var docVC: UIDocumentInteractionController?
    let pdfLink = "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
    var fileURL: URL?
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        docVC = UIDocumentInteractionController()
        docVC?.delegate = self
        
        btnViewFile.layer.borderColor = (btnViewFile.titleLabel?.textColor ?? UIColor.lightGray).cgColor
        btnViewFile.layer.borderWidth = 1.0
        btnViewFile.layer.cornerRadius = 5.0
    }
    // MARK:- SetUpView
    private func showLoader() {
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    private func hideLoader() {
        activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    // MARK:- Button Actions
    @IBAction func btnViewFilePressed(_ sender: UIButton) {
        guard let _url = fileURL else {
            sender.isHidden = true
            return
        }
        self.share(controller: self.docVC!, url: _url)
    }
    
    @IBAction private func btnDownloadPressed(_ sender: UIButton) {
        showLoader()
        downloadFile { (path, str) in
            self.hideLoader()
            guard let localPath = path, str == nil else {
                debugPrint(str ?? enumErrMessage.Oops.rawValue)
                return
            }
            if self.docVC != nil {
                self.share(controller: self.docVC!, url: localPath)
            }
        }
    }
    
    @IBAction private func btnUploadPressed(_ sender: UIButton) {
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeRTF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    // MARK:- Custom Methods
    func downloadFile(complection: @escaping(URL?, String?) -> Void ) {
        let finaleURL = pdfLink
        let tempFileExt = "SamplePDF.pdf"
        guard let url = URL(string: finaleURL) else {
            DispatchQueue.main.async {
                complection(nil, enumErrMessage.Oops.rawValue)
            }
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data, err == nil else {
                DispatchQueue.main.async {
                    complection(nil, err?.localizedDescription ?? enumErrMessage.Oops.rawValue)
                }
                return
            }
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(tempFileExt) //FileManager.default.temporaryDirectory.appendingPathComponent(response?.suggestedFilename ?? tempFileExt)
            do {
                try data.write(to: tempURL)
            } catch let fileErr {
                DispatchQueue.main.async {
                    complection(nil, fileErr.localizedDescription)
                    return
                }
            }
            DispatchQueue.main.async {
                complection(tempURL, nil)
            }
            }.resume()
    }
    func share(controller: UIDocumentInteractionController, url: URL) {
        controller.url = url
        controller.uti = url.typeIdentifier ?? "public.data, public.content"
        controller.name = url.localizedName ?? url.lastPathComponent
        controller.presentPreview(animated: true)
    }
    private func showViewButton(){
        self.alBottonCons.constant = 30
        self.btnViewFile.isHidden = false
        UIView.animate(withDuration: 3, delay: 1, usingSpringWithDamping: 2.0, initialSpringVelocity: 8.0, options: .curveEaseIn, animations: {
            self.alBottonCons.constant = -40
        }) { (_ isComplete) in
            self.alBottonCons.constant = -30
        }
    }
    // MARK:- Receive Memory Warining
    override func didReceiveMemoryWarning() {
        debugPrint("Receive Memory Warning \(String(describing: self))")
    }
    // MARK:- dinit
    deinit {
        debugPrint("\(String(describing: self)) removed.")
    }
}//class

// MARK:- Extension for UIDocumentInteractionControllerDelegate
extension DashboardVC: UIDocumentInteractionControllerDelegate {
    /// If presenting atop a navigation stack, provide the navigation controller in order to animate in a manner consistent with the rest of the platform
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let navVC = self.navigationController else {
            return self
        }
        return navVC
    }
}//extension
// MARK:- Extension for UIDocumentPickerDelegate
extension DashboardVC: UIDocumentPickerDelegate, UINavigationControllerDelegate  {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            self.fileURL = fileURL
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showViewButton()
            }
            debugPrint(data)
        } catch {
            print(error.localizedDescription)
        }
        debugPrint(fileURL, fileURL.absoluteString)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}//extension
// MARK:- Extension for URL
extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}//extension
