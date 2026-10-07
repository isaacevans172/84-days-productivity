//
//  FocusPlaceholderView.swift
//  84Days
//
//  Created by Isaac Evans on 7/10/2026.
//


import SwiftUI

struct FocusPlaceholderView: View {

    private let coral = Color(
        red: 1.0,
        green: 0.451,
        blue: 0.349
    )

    var body: some View {

        VStack(spacing: 18) {

            Image(systemName: "circle.dashed")
                .font(.system(size: 48))
                .foregroundStyle(coral)

            Text("Focus")
                .font(.system(
                    size: 30,
                    weight: .bold
                ))

            Text(
                "Focus tools will live here."
            )
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .navigationTitle("Focus")
    }
}