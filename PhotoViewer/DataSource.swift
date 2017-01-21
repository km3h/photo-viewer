//
//  DataSource.swift
//  PhotoViewer
//
//  Created by ASIM27 on 11/16/16.
//  Copyright © 2016 km3h. All rights reserved.
//

import UIKit

enum DataSourcePhotoType
{
    case THUMBNAIL
    case FULLPHOTO
}

enum URLSessionType
{
    case Delegate
    case CompletionHandler
    case Default
}

class DataSource: NSObject
{
    var urlRequest : URLRequest?
    var urlRequestOffline : URLRequest?
    var shouldReadFromCache : Bool?
    public var urlSessionType : URLSessionType?
    
    typealias handlerName = ([NSNumber : [[String : AnyObject]]]?) -> Void
    var handler : handlerName?
    
    override init()
    {
        super.init()
        self.createPhotoDirectory()
    }
    
    public var urlString : String? {
        didSet {
            guard let urlString = self.urlString else {
                return
            }
            
            guard let url = URL(string: urlString) else {
                return
            }
            self.urlRequest = URLRequest(url: url)
            self.urlRequestOffline = URLRequest(url: url as URL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10.0)
        }
    }
    
    func createPhotoDirectory() -> Void
    {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsURL.appendingPathComponent("images").path
        
        if FileManager.default.fileExists(atPath: dataPath)
        {
            return
        }
        
        do
        {
            try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
        }
        catch let error as NSError
        {
            print(error.localizedDescription);
        }
    }
    
    func genericTaskHandler(data :Data?, response : URLResponse?, error: Error?) -> Void
    {
        if let httpResponse = response as? HTTPURLResponse
        {
            let statusCode = httpResponse.statusCode
            if (statusCode == 200 || statusCode == 304)
            {
                do
                {
                    guard let data = data else
                    {
                        print("Error with Json1: \(error)")
                        return
                    }
                    
                    guard let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [NSDictionary] else
                    {
                        print("Error with Json2: \(error)")
                        return
                    }
                    
                    guard let handler = self.handler else
                    {
                        print("Error with Json3: \(error)")
                        return
                    }
                    
                    handler(self.transformData(json: json))
                    
                }
                catch
                {
                    print("Error with Json4: \(error)")
                }
            }
        }
    }
    
    func taskHandler(data :Data?, response : URLResponse?, error: Error?) -> Void
    {
        if let error = error
        {
            print("error \(error)")
        }
        
        if (response as? HTTPURLResponse) != nil
        {
            self.genericTaskHandler(data: data, response: response, error: error)
        }
        else
        {
            let taskOffline = self.getSession(handler : taskHandlerOffline)?.dataTask(with: self.urlRequestOffline!)
            taskOffline?.resume() // read from nsurlcache if offline
        }
    }
    
    func taskHandlerOffline(data :Data?, response : URLResponse?, error: Error?) -> Void
    {
        if let error = error
        {
            print("error \(error)")
        }
        
        if (response as? HTTPURLResponse) != nil
        {
            self.genericTaskHandler(data: data, response: response, error: error)
        }
    }
    
    public func data(handler : @escaping ([NSNumber : [[String : AnyObject]]]?) -> Void)
    {
        var dataTask : URLSessionDataTask?
        self.handler = handler
        
        switch self.urlSessionType
        {
        case .some(.Delegate), .some(.Default):
            dataTask = self.getSession(handler : taskHandler)?.dataTask(with: self.urlRequest!)
        case .some(.CompletionHandler):
            dataTask = self.getSession(handler: taskHandler)?.dataTask(with: self.urlRequest!, completionHandler: taskHandler)
        default:
            print("default")
        }
        
        dataTask?.resume()
    }
    
    func getSession(handler : @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSession?
    {
        return URLSession(configuration: .default, delegate: SessionDelegate(handler: handler), delegateQueue: nil)
    }
    
    func serializeJson(json data : Data?) -> [NSDictionary]?
    {
        if let data = data {
            do
            {
                let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? [NSDictionary]
                return json
            }
            catch
            {
                print("caught: \(error)")
                return nil
            }
        }
        return nil
    }
    
    func transformData(json : [NSDictionary]) -> [NSNumber : [[String : AnyObject]]]
    {
        var transformedData = [NSNumber : [[String : AnyObject]]]()
        
        for photo in json
        {
            if let albumName = photo["albumId"] as? NSNumber
            {
                if transformedData[albumName] != nil
                {
                    transformedData[albumName]!.append(photo as! [String : AnyObject])
                }
                else
                {
                    var photoArray = [[String : AnyObject]]()
                    photoArray.append(photo as! [String : AnyObject])
                    transformedData[albumName] = photoArray
                }
            }
        }
        return transformedData
    }
    
    public func photo (photoType: DataSourcePhotoType , photo : [String:AnyObject]?, handler : @escaping (UIImage?) -> Void)
    {
        guard let photoName = photo?["id"] else {
            return
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath : String
        let photoPath : String
        if  photoType == .THUMBNAIL {
            filePath = documentsURL.appendingPathComponent("images/\(photoName)_thumbnail.png").path
            photoPath = photo!["thumbnailUrl"] as! String
        }
        else
        {
            filePath = documentsURL.appendingPathComponent("images/\(photoName)_fullPhoto.png").path
            photoPath = photo!["url"] as! String
        }
        
        if FileManager.default.fileExists(atPath: filePath)
        {
            handler(UIImage(contentsOfFile: filePath))
        }
        else
        {
            let fileURL = URL(fileURLWithPath: filePath)
            
            DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
                do
                {
                    let data = try Data(contentsOf: URL(string: photoPath)!)
                    let getImage = UIImage(data: data)
                    try data.write(to: fileURL)
                    DispatchQueue.main.async {
                        handler(getImage)
                    }
                }
                catch
                {
                    return
                }
            }
        }
    }
    
}
