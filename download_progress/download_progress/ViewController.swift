//
//  ViewController.swift
//  download_progress
//
//  Created by Leo Nugraha on 2022/9/6.
//

import UIKit
import Photos
import Foundation

let TARGET_URL: String = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"

class ViewController: UIViewController {

    private lazy var urlSessionDownload: URLSession = {
        let configuration                      = URLSessionConfiguration.default
        configuration.allowsCellularAccess     = true
        configuration.isDiscretionary          = false // w/o energy optimization
        configuration.requestCachePolicy       = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        configuration.sessionSendsLaunchEvents = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    private lazy var progressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.setProgress(0.0, animated: true)
        progress.progressTintColor = .systemBlue
        return progress
    }()

    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setTitle("CANCEL", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    @objc private func cancelButtonTapped() {
        print("Cancel button tapped")
    }

    // TODO: - How this part needs to be adjusted
    @objc private func downloadButtonTapped() {
        print("Downloading an item starts now")
        
        // TODO: - Display % progress, but the closure is removed
        // let task = self.urlSessionDownload.downloadTask(with: URL(string: TARGET_URL)!)
        
        // TODO: - The closure stays and video can be saved, but display % progress does not increment

        /*
        let task = self.urlSessionDownload.downloadTask(with: URL(string: TARGET_URL)!) { url, response, error in
            guard let urlUnwrapped = url else { return }
            if let urlData = NSData(contentsOf: urlUnwrapped) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let filePath = "\(documentsPath)/TEST_VIDEO_FILE.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            print("Download is completed")
                        } else {
                            print("Download failed")
                        } // end-if completed
                    }
                }
            } // end-if
        }
         */
    
        let task = self.urlSessionDownload.downloadTask(with: URL(string: TARGET_URL)!) { url, response, error in
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath = "\(documentsPath)/TEMP_VIDEO_FILE.mp4"
            // DispatchQueue.global(qos: .background).async {
                UISaveVideoAtPathToSavedPhotosAlbum(filePath, nil, "video:didFinishSavingWithError:contextInfo:", nil)
            // }
        }

        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.downloadButton)
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.cancelButton)

        self.downloadButton.translatesAutoresizingMaskIntoConstraints = false
        self.progressBar.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.downloadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.downloadButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.downloadButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            self.downloadButton.heightAnchor.constraint(equalToConstant: 60),
            
            self.progressBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.progressBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.progressBar.topAnchor.constraint(equalTo: self.downloadButton.bottomAnchor, constant: 10),
            self.progressBar.heightAnchor.constraint(equalToConstant: 20),
            
            self.cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.cancelButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -80),
            self.cancelButton.heightAnchor.constraint(equalToConstant: 60),
        ])

    }
}

extension ViewController: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download is complete")
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressBar.setProgress(calculatedProgress, animated: true)
            print("Download Progress: \(calculatedProgress*100.0)%")
        }
    }
    
}

