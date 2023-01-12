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
