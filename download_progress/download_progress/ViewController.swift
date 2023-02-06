//
//  ViewController.swift
//  download_progress
//
//  Created by Leo Nugraha on 2022/9/6.
//

import UIKit
import Photos
import Foundation
import ActivityKit

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
        progress.progressTintColor = .systemOrange
        return progress
    }()

    private lazy var downloadButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .orange
        button.setTitle("Download Now", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
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

    @objc private func downloadButtonTapped() {
        print("Downloading an item starts now")
        
        // TODO: - Display % progress, but the closure is removed
        let task = self.urlSessionDownload.downloadTask(with: URL(string: TARGET_URL)!)
        
        if #available(iOS 16.1, *) {
            launchDownloadProgressActivity(percentDownloaded: 0.0,
                                           downloadFileSize: 0.0,
                                           totalFileSize: 1000.0)
        } else {
            // Fallback on earlier versions
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

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        print("\(#function) \(#line): Download is complete")

        if let urlData = NSData(contentsOf: location) {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
            let filePath="\(documentsPath)/BUNNY_VIDEO.mp4"

            DispatchQueue.global(qos: .background).async {
                urlData.write(toFile: filePath, atomically: true)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                }) { completed, error in
                    if completed {
                        print("\(#function) \(#line): Download is saved to Photo Album")
                        if #available(iOS 16.1, *) {
                            terminateDownloadProgressActivity()
                        } else {
                            // Fallback on earlier versions
                        }
                    } // end-if completed
                }
            } // end DispatchQueue.main.async
        } // end-if
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {

            if #available(iOS 16.1, *) {
                updateDownloadProgressActivity(percentDownloaded: Double(calculatedProgress * 100.0),
                                               downloadFileSize: Double(totalBytesWritten))
            } else {
                // Fallback on earlier versions
            }

            self.progressBar.setProgress(calculatedProgress, animated: true)
            print("Download Progress: \(calculatedProgress*100.0)%")
        }
    }
    
}

// MARK: - Live Activities
struct DownloadProgressAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        var percentProgress: Double
        var downloadProgress: Double
    }

    var totalFileSize: Double
}

@available(iOS 16.1, *)
func launchDownloadProgressActivity(percentDownloaded: Double,
                                    downloadFileSize: Double,
                                    totalFileSize: Double) {
    
    let downloadProgressAttribute = DownloadProgressAttributes(totalFileSize: totalFileSize)
    let initialContentState = DownloadProgressAttributes.ContentState(percentProgress: percentDownloaded,
                                                                      downloadProgress: downloadFileSize)

    do {
        let downloadActivity = try Activity<DownloadProgressAttributes>.request(attributes: downloadProgressAttribute,
                                                                                contentState: initialContentState,
                                                                                pushType: nil)
        print("\(#function) at line: \(#line): Live Activity has been initialized successfully (\(downloadActivity.id))")

    } catch (let error) {
        print("\(#function) at line: \(#line): An error happened while initializing Live Activity")
    }
    
}

@available(iOS 16.1, *)
func terminateDownloadProgressActivity() {
    Task {
        for activity in Activity<DownloadProgressAttributes>.activities{
            await activity.end(dismissalPolicy: .immediate)
        }
    }
}

@available(iOS 16.1, *)
func updateDownloadProgressActivity(percentDownloaded: Double,
                                    downloadFileSize: Double) {

    Task {
        let updatedDownloadProgressStatus = DownloadProgressAttributes.ContentState(percentProgress: percentDownloaded,
                                                                                    downloadProgress: downloadFileSize)

        for activity in Activity<DownloadProgressAttributes>.activities{
            await activity.update(using: updatedDownloadProgressStatus)
        }
    }

}
