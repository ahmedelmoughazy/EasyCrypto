//
//  PriceView.swift
//  EasyCrypto
//
//  Created by Mehran on 12/17/1401 AP.
//

import SwiftUI

struct PriceView: View {

    let item: MarketsPrice
    
    var viewModel: DetailViewModel

    @State var isPersist: Bool = false

    var body: some View {
        VStack {
            HStack {
                CoinRankView(image: Assets.hashtag, rank: item.marketCapRank ?? 0)
                Text(Constants.PlaceHolder.globalRank)
                    .foregroundColor(Color.gray)
                    .font(FontManager.body)
                Spacer()
                Button {
                    self.handleDataPersistence(for: item)
                } label: {
                    Image(isPersist ? Assets.save : Assets.unsave)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20.0, height: 20.0)
                }
            }
            HStack {
                Text(item.name.orWhenNilOrEmpty(.empty))
                    .foregroundColor(Color.white)
                    .font(FontManager.headLine)
                Spacer()
            }
            HStack {
                let price = CurrencyFormatter.sharedInstance.string(from: item.currentPrice?.toNSNumber ?? 0)!
                Text(price)
                    .foregroundColor(Color.white)
                    .font(FontManager.headLine)
                Spacer()
                ImageView(withURL: item.safeImageURL())
                    .frame(width: 40.0, height: 40.0)
            }
            .padding(.top)
            HStack {
                if let priceChange = CurrencyFormatter.sharedInstance.string(from: item.priceChangePercentage24H?.toNSNumber ?? 0) {
                    Text(priceChange)
                        .foregroundColor(item.priceChangePercentage24H?.sign == .minus ? Color.red : Color.lightGreen)
                        .font(FontManager.title)
                    Spacer()
                }
            }
        }
        .onAppear {
            self.isPersist = self.viewModel.checkIfItemExist(item)
        }
    }

    private func handleDataPersistence(for item: MarketsPrice) {
        isPersist.toggle()

        if isPersist {
            viewModel.addToWishlist(item)
        } else {
            viewModel.deleteFromWishlist(item)
        }
    }
}
