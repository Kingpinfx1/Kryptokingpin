import SwiftUI
import Charts

struct DetailView: View {
    @StateObject private var vm: DetailViewModel
    @State private var showFullDescription: Bool = false
    
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(coin: CoinModel) {
        _vm = StateObject(wrappedValue: DetailViewModel(coin: coin))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Chart
                chartView
                    .frame(height: 250)
                    .padding(.vertical)
                
                // Overview
                overviewSection
                
                // Additional Stats
                additionalStatsSection
                
                // Description
                if let description = vm.description {
                    descriptionSection(description)
                }
                
                // Links
                if let websiteURL = vm.websiteURL, let redditURL = vm.redditURL {
                    linksSection(websiteURL: websiteURL, redditURL: redditURL)
                }
            }
            .padding()
        }
        .navigationTitle(vm.coin.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Text(vm.coin.symbol.uppercased())
                        .font(.headline)
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
    }
}

extension DetailView {
    private var chartView: some View {
        Chart {
            ForEach(Array(vm.chartData.enumerated()), id: \.offset) { index, value in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Price", value)
                )
                .foregroundStyle(Color.theme.accent.gradient)
            }
        }
        .chartYScale(domain: .automatic(includesZero: false))
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Overview")
                .font(.title)
                .bold()
                .foregroundColor(Color.theme.accent)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                ForEach(vm.statistics) { stat in
                    StatisticView(stat: stat)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.15), radius: 10)
        )
    }
    
    private var additionalStatsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Additional Stats")
                .font(.title)
                .bold()
                .foregroundColor(Color.theme.accent)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                ForEach(vm.additionalStats) { stat in
                    StatisticView(stat: stat)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.15), radius: 10)
        )
    }
    
    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("About \(vm.coin.name)")
                .font(.title)
                .bold()
                .foregroundColor(Color.theme.accent)
            
            Text(description)
                .lineLimit(showFullDescription ? nil : 3)
                .font(.callout)
                .foregroundColor(Color.theme.secondaryText)
            
            Button(action: {
                withAnimation(.easeInOut) {
                    showFullDescription.toggle()
                }
            }) {
                Text(showFullDescription ? "Show less" : "Read more...")
                    .font(.caption)
                    .bold()
                    .foregroundColor(Color.theme.accent)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.15), radius: 10)
        )
    }
    
    private func linksSection(websiteURL: String, redditURL: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Links")
                .font(.title)
                .bold()
                .foregroundColor(Color.theme.accent)
            
            Link(destination: URL(string: websiteURL)!) {
                HStack {
                    Image(systemName: "globe")
                    Text("Website")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                }
                .foregroundColor(Color.theme.accent)
            }
            
            Link(destination: URL(string: redditURL)!) {
                HStack {
                    Image(systemName: "link")
                    Text("Reddit")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                }
                .foregroundColor(Color.theme.accent)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.theme.background)
                .shadow(color: Color.theme.accent.opacity(0.15), radius: 10)
        )
    }
}

struct StatisticView: View {
    let stat: StatisticModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(stat.title)
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
            
            Text(stat.value)
                .font(.headline)
                .foregroundColor(Color.theme.accent)
            
            if let percentageChange = stat.percentageChange {
                HStack(spacing: 4) {
                    Image(systemName: percentageChange >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(percentageChange.asPercentString())
                }
                .font(.caption)
                .foregroundColor(
                    percentageChange >= 0 ?
                    Color.theme.green :
                    Color.theme.red
                )
            }
        }
    }
}

#Preview {
    NavigationView {
        DetailView(coin: DeveloperPreview.instance.coin)
    }
} 