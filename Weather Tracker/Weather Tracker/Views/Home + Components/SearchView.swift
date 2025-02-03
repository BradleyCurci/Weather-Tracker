//
//  SearchView.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/30/25.
//

import SwiftUI

struct SearchView: View {
    var viewModel: WeatherManagerViewModel
    @Binding var searchQuery: String
    @Binding var isFocused: Bool
    @FocusState private var searchFieldIsFocused: Bool
    
    @Binding var showingNilLocationBanner: Bool
    
    var body: some View {
        HStack {
            TextField("Search Location", text: $searchQuery)
                .focused($searchFieldIsFocused)
                .autocorrectionDisabled()
                .onAppear {
                    searchFieldIsFocused = isFocused
                }
                .onChange(of: searchFieldIsFocused, initial: false) {
                    if isFocused == false {
                        isFocused = true
                    } else {
                        isFocused = false
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Button("Search") {
                            searchFieldIsFocused = false
                            Task {
                                if await !viewModel.loadWeather(searchQuery) {
                                    self.showingNilLocationBanner.toggle()
                                }
                            }
                        }
                    }
                }
            
            Spacer()
            if !isFocused {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.text.opacity(0.3))
            } else {
                Button {
                    searchFieldIsFocused = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.text.opacity(0.6))
                }
            }
        }
        .font(.system(size: 18))
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.text.opacity(0.1))
        .clipShape(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
        )
    }
}

#Preview {
    SearchView(viewModel: WeatherManagerViewModel.preview, searchQuery: .constant(""), isFocused: .constant(true), showingNilLocationBanner: .constant(false))
}
