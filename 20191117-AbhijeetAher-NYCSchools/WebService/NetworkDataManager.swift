//
//  NetworkDataManager.swift
//  20191117-AbhijeetAher-NYCSchools
//
//  Created by Abhijeet Aher on 11/17/19.
//  Copyright © 2019 Abhijeet Aher. All rights reserved.
//

import UIKit

enum Result<T, Error> {
    case success(T)
    case error(Error)
}

enum DownloadErrors: Error {
    case failedToDownload
}
class NetworkDataManager: NSObject {

    // Progress Handler Closure
    typealias ProgressClosure = (Float) -> ()
    typealias CompletionClosure = (Result<Any, Error>) -> ()

    fileprivate var completionHandlerDict: [Int:CompletionClosure] = [:]
    fileprivate var progressHandlerDict: [Int:ProgressClosure] = [:]
    fileprivate var progressHandler: ProgressClosure!
    fileprivate var completionHandler: CompletionClosure!
    fileprivate var currentRunningTask: URLSessionDataTask!
    // Singleton instance
    static let sharedNetworkmanager = NetworkDataManager()

    // Save images in cache
    static let sharedCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.name = "MyImageCache"
        cache.countLimit = 20 // Max 20 images in memory.
        cache.totalCostLimit = 10*1024*1024 // Max 10MB used.
        return cache
    }()
    // Create a session
    lazy var session: URLSession = {

        let config = URLSessionConfiguration.default
        config.urlCache = nil

        return URLSession(configuration: config)
    }()
    lazy var backgroundSession: URLSession = {

        let config = URLSessionConfiguration.background(withIdentifier: "Download")
        config.urlCache = nil
        config.httpMaximumConnectionsPerHost = 5
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }()

    // Method to fetch data from URL
    func fetchDataWithUrlRequest(_ urlRequest: URLRequest, completion:@escaping (_ success: Bool, _ fetchedData: Data?) -> Void) {

        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
                completion(false, nil)
            } else {
                completion(true, data!)
            }
        })
        currentRunningTask = task
        task.resume()

    }
    func cancelOnGoingTasks() {
        currentRunningTask.cancel()
    }
    func downloadFileWithRequest(_ urlRequest: URLRequest, completion:@escaping (Result<Any, Error>) -> Void, progressHandler:@escaping (Float) -> Void) ->URLSessionDownloadTask {

        self.completionHandler = completion
        self.progressHandler = progressHandler
        let downloadTask = backgroundSession.downloadTask(with: urlRequest)
        if !completionHandlerDict.keys.contains(downloadTask.taskIdentifier) {
            completionHandlerDict[downloadTask.taskIdentifier] = completion
        }
        if !progressHandlerDict.keys.contains(downloadTask.taskIdentifier) {
            progressHandlerDict[downloadTask.taskIdentifier] = progressHandler
        }
        return downloadTask
    }
    func resumeDownloadWithData(resumeData: Data, completion:@escaping (Result<Any, Error>) -> Void, progressHandler:@escaping (Float) -> Void) ->URLSessionDownloadTask {

        self.completionHandler = completion
        self.progressHandler = progressHandler
        let downloadTask = backgroundSession.downloadTask(withResumeData: resumeData)
        if !completionHandlerDict.keys.contains(downloadTask.taskIdentifier) {
            completionHandlerDict[downloadTask.taskIdentifier] = completion
        }
        if !progressHandlerDict.keys.contains(downloadTask.taskIdentifier) {
            progressHandlerDict[downloadTask.taskIdentifier] = progressHandler
        }
        return downloadTask
    }

    func getCompletionHandlerForTask(identifier: Int) -> CompletionClosure? {

        if completionHandlerDict.keys.contains(identifier) {
            return completionHandlerDict[identifier]
        }
        return nil
    }

    func getProgressHandlerForTask(identifier: Int) -> ProgressClosure? {

        if progressHandlerDict.keys.contains(identifier) {
            return progressHandlerDict[identifier]
        }
        return nil
    }
    func removeCompletionHandlerForTask(identifier: Int) {

        if completionHandlerDict.keys.contains(identifier) {
            completionHandlerDict.removeValue(forKey: identifier)
        }
    }

    func removeProgressHandlerForTask(identifier: Int) {

        if progressHandlerDict.keys.contains(identifier) {
            progressHandlerDict.removeValue(forKey: identifier)
        }
    }
}

extension NetworkDataManager:URLSessionDownloadDelegate {

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let fileManager = FileManager()
        let destinationFileName = downloadTask.originalRequest?.url?.lastPathComponent ?? "Unknown"
        let destinationURLForFile = URL(fileURLWithPath: cachesPath!.appendingFormat(destinationFileName))
        let completionHandler = getCompletionHandlerForTask(identifier: downloadTask.taskIdentifier)
        if fileManager.fileExists(atPath: destinationURLForFile.path) {
            completionHandler!(.success(true))
            do {
                removeCompletionHandlerForTask(identifier: downloadTask.taskIdentifier)
                removeProgressHandlerForTask(identifier: downloadTask.taskIdentifier)
            }
        } else {
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                completionHandler!(.success(true))
                do {
                    removeCompletionHandlerForTask(identifier: downloadTask.taskIdentifier)
                    removeProgressHandlerForTask(identifier: downloadTask.taskIdentifier)
                }

            } catch let error {

                completionHandler!(.error(error))
                do {
                    removeCompletionHandlerForTask(identifier: downloadTask.taskIdentifier)
                    removeProgressHandlerForTask(identifier: downloadTask.taskIdentifier)
                }
            }
        }

    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        let progressPercentage = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        let progressHandler = getProgressHandlerForTask(identifier: downloadTask.taskIdentifier)
        print(progressPercentage)
        progressHandler!(progressPercentage)
    }

}
extension URL {

    typealias ImageCacheCompletion = (UIImage) -> Void

    /// Retrieves a pre-cached image, or nil if it isn't cached.
    /// You should call this before calling fetchImage.
    var cachedImage: UIImage? {
        return NetworkDataManager.sharedCache.object(
            forKey: absoluteString as NSString)
    }
    func isValidUrl() -> Bool {

        if(self.scheme!.hasPrefix("http") || (self.scheme?.hasPrefix("https"))!) {
            return true
        }
        return false
    }
    /// Fetches the image from the network.
    /// Stores it in the cache if successful.
    /// Only calls completion on successful image download.
    /// Completion is called on the main thread.
    func fetchImage(_ completion: @escaping ImageCacheCompletion) {
        let task = URLSession.shared.dataTask(with: self, completionHandler: {
            data, response, error in
            if error == nil {
                if let  data = data,
                    let image = UIImage(data: data) {
                    NetworkDataManager.sharedCache.setObject(
                        image,
                        forKey: self.absoluteString as NSString,
                        cost: data.count)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        })
        task.resume()
    }

}

extension String {

    func isValidForUrl() -> Bool {

        if(self.hasPrefix("http") || self.hasPrefix("https")) {
            return true
        }
        return false
    }
}

