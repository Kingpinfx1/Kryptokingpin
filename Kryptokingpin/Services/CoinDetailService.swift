import Foundation
import Combine

class CoinDetailService {
    private var coinDetailSubscription: AnyCancellable?
    
    func getCoinDetails(for coinId: String) -> AnyPublisher<CoinDetailModel?, Error> {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinId)?localization=false&tickers=false&market_data=false&community_data=false&developer_data=false&sparkline=false") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return NetworkingManager.download(url: url)
            .decode(type: CoinDetailModel.self, decoder: JSONDecoder())
            .map { Optional($0) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
} 