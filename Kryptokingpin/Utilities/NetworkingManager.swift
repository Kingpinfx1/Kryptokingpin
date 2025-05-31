//
//  NetworkingManager.swift
//  Kryptokingpin
//
//  Created by kingpin on 4/24/25.
//

import Foundation
import Combine

class NetworkingManager {
    
    enum NetworkingError: LocalizedError {
        case badURLResponse
        case unknmown
        
        var errorDescription: String?{
            switch self {
            case .badURLResponse: return "[🔥] Bad response from url"
            case .unknmown : return " [😨]Unknown error occured"
            }
        }
    }
    
    static func download(url : URL) -> AnyPublisher<Data, Error>{
       return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap({ try handleURLResponse(output: $0)})
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output) throws -> Data{
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            //throw URLError(.badServerResponse)
            throw NetworkingError.badURLResponse
        }
        return output.data
    }
    
    static func handleCompletion(completion: Subscribers.Completion<any Error>){
        switch completion{
        case .finished:
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
