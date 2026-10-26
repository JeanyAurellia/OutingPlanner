import SwiftUI

public struct PlacePickerView: View {
    @State private var viewModel: PlaceSearchViewModel
    private let onSelect: (PlaceResult) -> Void

    public init(
        apiKey: String,
        onSelect: @escaping (PlaceResult) -> Void = { _ in }
    ) {
        self.onSelect = onSelect

        let service = GeoapifyPlaceService(apiKey: apiKey)
        _viewModel = State(
            initialValue: PlaceSearchViewModel(service: service)
        )
    }

    public var body: some View {
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
    }
}
