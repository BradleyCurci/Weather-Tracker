//
//  MyLocationsView.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/30/25.
//

import SwiftUI

struct MyLocationsView: View {
    @ObservedObject var coreDataManager = CoreDataManager.shared
    
    @StateObject var viewModel = WeatherManagerViewModel.shared
    
    @State private var savedLocations: [WeatherModel] = []
    @State private var searchQuery: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        if coreDataManager.locations.isEmpty {
            VStack(alignment: .leading) {
                Spacer()
                Text("No Locations")
                    .font(.largeTitle)
                
                Text("This is where your saved locations will appear")
                    .foregroundStyle(.text.opacity(0.5))
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            ScrollView {
                ForEach(searchResults(searchQuery)) { location in
                    Button {
                        Task {
                            if  await viewModel.loadWeather(location.location.name) {
                                dismiss()
                            }
                        }
                    } label: {
                        LocationItem(location: location.location.name, temp: getTemp(location, viewModel: viewModel), icon: location.current.condition.icon)
                    }
                }
            }
            .padding(.horizontal)
            .toolbar {
                Button {
                    for location in savedLocations {
                        coreDataManager.deleteLocation(location: location.location.name)
                    }
                } label: {
                    Text("Clear all")
                        .foregroundStyle(.red)
                }
            }
            .onAppear {
                coreDataManager.fetchLocations()
                
                for location in coreDataManager.locations {
                    Task {
                        if await viewModel.loadWeather(location.name ?? "") {
                            savedLocations.append(viewModel.response!)
                        }
                    }
                }
                
            }
            .navigationTitle("My Locations")
            .searchable(text: $searchQuery)
        }
    }
    
    private func searchResults(_ searchQuery: String) -> [WeatherModel] {
        if searchQuery.isEmpty {
            return savedLocations
        } else {
            return savedLocations.filter { item in
                item.location.name.contains(searchQuery)
            }
        }
    }
}


#Preview {
    MyLocationsView()
}
