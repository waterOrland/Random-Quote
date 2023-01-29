//
//  QuoteManager.swift
//  Random Quote
//
//  Created by Orland Tompkins.
//

import Foundation

protocol QuoteDataDelegate {
    func sendData(_ quoteModel: QuoteModel)
    func didFailWithError(error: Error)
}


struct QuoteManager {
    let url = "https://api.quotable.io/"
    
    var delegate: QuoteDataDelegate?
    
    func fetchQuote() {
        let urlString = "\(url)" + "random"
        performRequest(with: urlString)
    }
    
    func fetchBio(name author: String) {
        let urlString = "\(url)+authors?slug=\(author)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let quoteModel = self.parseJSON(safeData) {
                        delegate?.sendData(quoteModel)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ quoteData: Data) -> QuoteModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(QuoteData.self, from: quoteData)
            let randomQuote = decodedData.content
            let authorName = decodedData.author
            let quoteModel = QuoteModel(randomQuote: randomQuote, authorName: authorName)
            return quoteModel
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

extension URLRequest {
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    init<T>(url: URL, method: HTTPMethod, body: T?) throws where T: Encodable {
        self.init(url: url)
        httpMethod = method.rawValue
        if let body = body {
            httpBody = try JSONEncoder().encode(body)
        }
    }
}

extension URLSession {
    func dataTask<T>(with request: URLRequest, callback: @escaping (T?, Error?) -> Void) throws -> URLSessionTask where T: Decodable {
        return URLSession.shared.dataTask(with: request) { data, response, error in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    callback(nil, error)
                    return
                }
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        callback(result, nil)
                    } catch let error {
                        callback(nil, error)
                    }
                } else {
                    callback(nil, nil)
                }
            }
            task.resume()
        }
    }
}
