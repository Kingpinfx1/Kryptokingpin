//
//  CoinLogoView.swift
//  Kryptokingpin
//
//  Created by kingpin on 4/30/25.
//

import SwiftUI
import Kingfisher

struct CoinLogoView: View {
    
    let coin : CoinModel
    
    var body: some View {
        VStack{
            KFImage(URL(string: coin.image))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .frame(width: 35, height: 35)
            Text(coin.symbol.uppercased())
                .font(.headline)
                .foregroundStyle(Color.theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(coin.name)
                .font(.caption)
                .foregroundStyle(Color.theme.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    CoinLogoView(coin: DeveloperPreview.instance.coin)
}
