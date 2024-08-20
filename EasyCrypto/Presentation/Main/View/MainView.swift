//
//  MainView.swift
//  EasyCrypto
//
//  Created by Mehran Kamalifard on 1/23/23.
//

import SwiftUI
import Combine

struct MainView: Coordinatable {
    
    typealias Route = Routes
    
    @ObservedObject var viewModel: MainViewModel
    
    enum Constant {
        static let searchHeight: CGFloat = 55
        static let topPadding: CGFloat = 5
        static let cornerRadius: CGFloat = 10
    }
    
    @State private var tabIndex = 0
    @State private var shouldShowDropdown = false
    @State private var searchText: String = .empty
    @State private var isLoading: Bool = false
    @State private var presentAlert = false
    @State private var alertMessage: String = .empty
    
    let subscriber = Cancelable()
    
    var body: some View {
        content
    }
    
    var content: some View {
        NavigationStack {
            ZStack {
                Color.darkBlue
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    SearchBar(isLoading: isLoading,
                              text: $viewModel.searchText,
                              isEditing: $shouldShowDropdown)
                    .padding(.horizontal, .regularSpace)
                    .overlay(
                        VStack {
                            if self.shouldShowDropdown {
                                Spacer(minLength: Constant.searchHeight + 10)
                                Dropdown(options: viewModel.searchData,
                                         onOptionSelected: { option in
                                    self.viewModel.didTapSecond(id: option.id.orWhenNilOrEmpty(.empty))
                                })
                                .padding(.horizontal)
                            }
                        }, alignment: .topLeading
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.clear)
                    )
                    .zIndex(1)
                    .padding(.top, Constant.topPadding)
                    SortView(viewModel: self.viewModel, isLoading: isLoading)
                        .padding(.top, Constant.topPadding)
                    TabItemView(index: $tabIndex)
                        .padding(.top, 20)
                    TabView(selection: $tabIndex) {
                        if tabIndex == 0 {
                            coinsList
                        } else {
                            whishList
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    Spacer()
                    if presentAlert {
                        self.showAlert(viewModel.errorTitle, alertMessage)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .navigationBarTitle(viewModel.title, displayMode: .inline)
            .navigationBarColor(backgroundColor: .clear, titleColor: .white)
            .onViewDidLoad {
                self.viewModel.apply(.onAppear)
            }
            .handleViewModelState(viewModel: viewModel,
                                  isLoading: $isLoading,
                                  alertMessage: $alertMessage,
                                  presentAlert: $presentAlert)
        }
    }
    
    private var coinsList: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.marketData, id: \.id) { item  in
                    CryptoCellView(marketPrice: item)
                        .onTapGesture {
                            self.viewModel.didTapFirst(item: item)
                        }
                }
                if isLoading {
                    ZStack {
                        RoundedRectangle(cornerRadius: Constant.cornerRadius)
                            .foregroundColor(Color.white.opacity(0.8))
                            .frame(width: 40.0, height: 40.0)
                        ActivityIndicator(style: .medium, animate: .constant(true))
                    }
                } else {
                    Color.clear
                        .onAppear {
                            if !isLoading, !self.viewModel.marketData.isEmpty {
                                self.viewModel.loadMore()
                            }
                        }
                }
            }
            .padding()
        }
    }
    
    private var whishList: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.wishListData, id: \.symbol) { item  in
                    CryptoCellView(marketPrice: item)
                        .onTapGesture {
                            self.viewModel.didTapFirst(item: item)
                        }
                }
            }
            .padding()
        }.onAppear {
            self.viewModel.fetchWishlistData()
        }
    }
}

extension MainView {
    enum Routes: Routing {
        case first(item: MarketsPrice)
        case second(id: String)
    }
}

extension MainView {
    func showAlert(_ title: String, _ message: String) -> some View {
        CustomAlertView(title: title, message: message, primaryButtonLabel: "Retry", primaryButtonAction: {
            self.presentAlert = false
            self.viewModel.callFirstTime()
        })
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
