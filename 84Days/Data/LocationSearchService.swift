//
//  LocationSearchService.swift
//  84Days
//
//  Created by Isaac Evans on 6/10/2026.
//


//
//  LocationSearchService.swift
//  84Days
//

import Foundation
import MapKit
import Combine

@MainActor
final class LocationSearchService: NSObject, ObservableObject {

    @Published var searchResults:
        [MKLocalSearchCompletion] = []

    private let completer =
        MKLocalSearchCompleter()

    override init() {

        super.init()

        completer.delegate = self

        completer.resultTypes = [
            .address,
            .pointOfInterest
        ]
    }

    func updateSearch(query: String) {

        if query
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty {

            searchResults = []
            return
        }

        completer.queryFragment = query
    }

    func clearResults() {

        searchResults = []
    }

    func selectResult(
        _ completion: MKLocalSearchCompletion
    ) async throws -> MKMapItem {

        let request =
            MKLocalSearch.Request(
                completion: completion
            )

        let search =
            MKLocalSearch(
                request: request
            )

        let response =
            try await search.start()

        guard let item =
                response.mapItems.first
        else {

            throw LocationSearchError.noResult
        }

        return item
    }
}


// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchService:
    MKLocalSearchCompleterDelegate {

    func completerDidUpdateResults(
        _ completer: MKLocalSearchCompleter
    ) {

        searchResults =
            completer.results
    }

    func completer(
        _ completer: MKLocalSearchCompleter,
        didFailWithError error: Error
    ) {

        searchResults = []

        print(
            "MapKit search error:",
            error.localizedDescription
        )
    }
}


// MARK: - Errors

enum LocationSearchError: Error {

    case noResult
}