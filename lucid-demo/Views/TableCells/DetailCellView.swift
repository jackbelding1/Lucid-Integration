//
//  DetailCellView.swift
//  lucid-demo2
//
//  Created by Jack Belding on 7/26/23.
//

import SwiftUI

struct DetailCellView: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct DetailCellView_Previews: PreviewProvider {
    static var previews: some View {
        DetailCellView(label: "Label", value: "Value")
    }
}
