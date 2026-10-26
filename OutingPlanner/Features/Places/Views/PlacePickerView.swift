//
//  PlacePickerView.swift
//  OutingPlanner
//
//  Created by Jeany Aurellia on 25/10/26.
//

import SwiftUI

struct PlacePickerView: View {
    @State private var viewModel: PlaceSearchViewModel
    private let onSelect: (PlaceResult) -> Void

    init(
        onSelect: @escaping (PlaceResult) -> Void = { _ in }
    ) {
        self.onSelect = onSelect

        let apiKey =
            ProcessInfo.processInfo.environment["GEOAPIFY_API_KEY"] ?? ""

        let service = GeoapifyPlaceService(apiKey: apiKey)

        _viewModel = State(
            initialValue: PlaceSearchViewModel(service: service)
        )
    }

    var body: some View {
        NavigationStack {
            List(viewModel.places) { place in
                Button {
                    onSelect(place)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(place.address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Cari Tempat")
            .searchable(
                text: $viewModel.searchText,
                prompt: "Cari tempat"
            )
            .onSubmit(of: .search) {
                Task {
                    await viewModel.search()
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.places.isEmpty,
                          !viewModel.searchText.isEmpty {
                    ContentUnavailableView(
                        "Tempat Tidak Ditemukan",
                        systemImage: "mappin.slash"
                    )
                }
            }
        }
    }}
