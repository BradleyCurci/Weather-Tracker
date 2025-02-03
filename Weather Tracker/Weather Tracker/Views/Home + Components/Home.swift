//
//  Home.swift
//  Weather Tracker
//
//  Created by Brad Curci on 1/29/25.
//

import SwiftUI

struct Home: View {
    
    @StateObject private var viewModel = WeatherManagerViewModel.shared
    
    @AppStorage("unit") private var unit: String = "f"
    
    @State var searchQuery: String = ""
    @State var currentLocation: String = ""
    
    @State private var showingConfirmationAlertAdd: Bool = false
    @State private var showingConfirmationAlertRemove: Bool = false
    
    @State private var isSearchBarFocused: Bool = false
    
    @State private var nilLocationBanner = BannerModifier.BannerData(
        title: "Error",
        detail: "No matching location found for the given input",
        type: .error)
    @State private var showingNilLocationBanner: Bool = false
    
    @State private var successfullyUpdatedBanner = BannerModifier.BannerData (
        title: "Success",
        detail: "Succesfully updated your saved locaitons list",
        type: .success)
    @State private var showingSuccessfullyUpdatebanner: Bool = false
    
    @State private var failedUpdatingBanner = BannerModifier.BannerData (
        title: "Error",
        detail: "Failed to updated your saved locations list",
        type: .error
    )
    @State private var showingErrorUpdatingBanner: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Toolbar
                HStack {
                    
                    NavigationLink {
                        MyLocationsView()
                    } label: {
                        Image(systemName: "list.dash")
                            .font(.title3)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button {
                            viewModel.updateUnit()
                        } label: {
                            Label("Change Units", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "gear")
                            .font(.title3)
                            .padding(.leading, 10)
                    }
                    
                    if let data = viewModel.response {
                        if !(CoreDataManager.shared.locations.contains(where: { $0.name == data.location.name})) {
                            Button {
                                currentLocation = data.location.name
                                showingConfirmationAlertAdd = true
                            } label: {
                                Text("Add")
                                    .foregroundStyle(.green)
                                    .font(.title3)
                                    .padding(.leading, 10)
                            }
                        } else {
                            Button {
                                currentLocation = data.location.name
                                showingConfirmationAlertRemove = true
                            } label: {
                                Text("Remove")
                                    .foregroundStyle(.red)
                                    .font(.title3)
                                    .padding(.leading, 10)
                            }
                        }
                    }
                }
                
                SearchView(viewModel: viewModel, searchQuery: $searchQuery, isFocused: $isSearchBarFocused, showingNilLocationBanner: $showingNilLocationBanner)
                
                if !isSearchBarFocused {
                    if let data = viewModel.response {
                        VStack(spacing: 30) {
                            
                            // Icon
                            let url = URL(string: "https:\(cleanURL(urlString: data.current.condition.icon))")
                            AsyncImage(url: url) { image in
                                image.resizable().frame(width: 130, height: 130)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 130, height: 130)
                            }
                            
                            // Location Name
                            VStack(spacing: 0){
                                HStack {
                                    Text(data.location.name)
                                        .font(.largeTitle)
                                    
                                    Image(systemName: "location.fill")
                                        .font(.title2)
                                }
                                
                                Text(data.location.region)
                                    .font(.system(size: 14))
                                    .kerning(1.07)
                                    .foregroundStyle(.text.opacity(0.5))
                            }
                            
                            // Temperature
                            VStack(spacing: -10) {
                                Text("\(getTemp(data, viewModel: viewModel))°")
                                    .font(.system(size: 70))
                                Text(viewModel.unit == "f" ? "Farenheit" : "Celcius")
                                    .kerning(1.07)
                                    .foregroundStyle(.text.opacity(0.5))
                            }
                            
                            // Metadata
                            HStack(spacing: 30) {
                                MetadataItem(title: "Humidity", value: data.current.humidity, suffix: "%")
                                
                                Divider()
                                    .frame(height: 20)
                                
                                MetadataItem(title: "UV", value: Int(data.current.uv), suffix: nil)
                                
                                Divider()
                                    .frame(height: 20)
                                
                                MetadataItem(title: "Feels Like", value: getFeelsLike(data, viewModel: viewModel), suffix: "°\(viewModel.unit.uppercased())")
                            }
                            .padding()
                            .background(.text.opacity(0.1))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            
                            Spacer()
                        }
                        .ignoresSafeArea(.keyboard)
                    } else if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                            VStack(alignment: .leading) {
                                Spacer()
                                Text("No City Selected")
                                    .font(.largeTitle)
                                
                                Text("Search for a city above, or browse from saved locations.")
                                    .foregroundStyle(.text.opacity(0.5))
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    Spacer()
                }
            }
            .padding(.horizontal)
            .alert(
                "Save \(currentLocation)?",
                isPresented: $showingConfirmationAlertAdd
            ) {
                Button("Cancel") {
                    showingConfirmationAlertAdd = false
                }
                Button("Save") {
                    CoreDataManager.shared.create(currentLocation)
                    showingSuccessfullyUpdatebanner = true
                }
            } message: {
                Text("\(currentLocation) will be added to your library.")
            }
            .alert(
                "Remove \(currentLocation)?",
                isPresented: $showingConfirmationAlertRemove
            ) {
                Button("Remove", role: .destructive) {
                    if  CoreDataManager.shared.locations.contains(where:  { $0.name == currentLocation }) {
                        let location = CoreDataManager.shared.locations.first(where: { $0.name == currentLocation})!
                        CoreDataManager.shared.deleteLocation(location: location.name!)
                    }
                    showingSuccessfullyUpdatebanner = true
                }
            } message: {
                Text("\(currentLocation) will be removed from your library.")
            }
            .banner(data: $nilLocationBanner, showing: $showingNilLocationBanner)
            .banner(data: $successfullyUpdatedBanner, showing: $showingSuccessfullyUpdatebanner)
        }
    }
}

struct MetadataItem: View {
    let title: String
    let value: Int
    let suffix: String?
    var body: some View {
        VStack {
            Text(title)
                .foregroundStyle(.text.opacity(0.3))
                .font(.system(size: 12))
            
            Text("\(value)\(suffix ?? "")")
                .foregroundStyle(.text.opacity(0.7))
        }
    }
}

#Preview {
    Home()
}
