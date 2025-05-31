import Foundation
import Combine

class DetailViewModel: ObservableObject {
    @Published var coin: CoinModel
    @Published var chartData: [Double] = []
    @Published var statistics: [StatisticModel] = []
    @Published var additionalStats: [StatisticModel] = []
    @Published var description: String? = nil
    @Published var websiteURL: String? = nil
    @Published var redditURL: String? = nil
    
    private let coinDetailService = CoinDetailService()
    private var cancellables = Set<AnyCancellable>()
    
    init(coin: CoinModel) {
        self.coin = coin
        self.addSubscribers()
        self.getCoinDetails()
    }
    
    private func addSubscribers() {
        // Update chart data
        $coin
            .map { coin -> [Double] in
                return coin.sparklineIn7D?.price ?? []
            }
            .sink { [weak self] returnedData in
                self?.chartData = returnedData
            }
            .store(in: &cancellables)
        
        // Update statistics
        $coin
            .map { coin -> [StatisticModel] in
                return [
                    StatisticModel(title: "Current Price", value: coin.currentPrice.asCurrencyWith6Decimals()),
                    StatisticModel(title: "Market Capitalization", value: "$" + (coin.marketCap?.formattedWithAbbreviations() ?? "")),
                    StatisticModel(title: "Rank", value: "#\(coin.rank)"),
                    StatisticModel(title: "Volume", value: "$" + (coin.totalVolume?.formattedWithAbbreviations() ?? ""))
                ]
            }
            .sink { [weak self] returnedStats in
                self?.statistics = returnedStats
            }
            .store(in: &cancellables)
        
        // Update additional statistics
        $coin
            .map { coin -> [StatisticModel] in
                return [
                    StatisticModel(title: "24h High", value: coin.high24H?.asCurrencyWith6Decimals() ?? "n/a"),
                    StatisticModel(title: "24h Low", value: coin.low24H?.asCurrencyWith6Decimals() ?? "n/a"),
                    StatisticModel(title: "24h Price Change", value: coin.priceChange24H?.asCurrencyWith6Decimals() ?? "n/a", percentageChange: coin.priceChangePercentage24H),
                    StatisticModel(title: "24h Market Cap Change", value: "$" + (coin.marketCapChange24H?.formattedWithAbbreviations() ?? ""), percentageChange: coin.marketCapChangePercentage24H),
                    StatisticModel(title: "Circulating Supply", value: coin.circulatingSupply?.formattedWithAbbreviations() ?? "n/a"),
                    StatisticModel(title: "Total Supply", value: coin.totalSupply?.formattedWithAbbreviations() ?? "n/a"),
                    StatisticModel(title: "Max Supply", value: coin.maxSupply?.formattedWithAbbreviations() ?? "n/a"),
                    StatisticModel(title: "All Time High", value: coin.ath?.asCurrencyWith6Decimals() ?? "n/a", percentageChange: coin.athChangePercentage),
                    StatisticModel(title: "All Time Low", value: coin.atl?.asCurrencyWith6Decimals() ?? "n/a", percentageChange: coin.atlChangePercentage)
                ]
            }
            .sink { [weak self] returnedStats in
                self?.additionalStats = returnedStats
            }
            .store(in: &cancellables)
    }
    
    private func getCoinDetails() {
        coinDetailService.getCoinDetails(for: coin.id)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching coin details: \(error)")
                }
            }, receiveValue: { [weak self] returnedDetails in
                self?.description = returnedDetails?.description?.en
                self?.websiteURL = returnedDetails?.links?.homepage?.first
                self?.redditURL = returnedDetails?.links?.subredditURL
            })
            .store(in: &cancellables)
    }
} 