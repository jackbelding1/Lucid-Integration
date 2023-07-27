//
//  TableCellView.swift
//  lucid-demo2
//
//  Created by Jack Belding on 7/26/23.
//

import SwiftUI

struct MainTableCellView: View {
    let identifier: String

    var body: some View {
        HStack {
            Text(identifier)
                .font(.headline)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct TableCellView_Previews: PreviewProvider {
    static var previews: some View {
        MainTableCellView(identifier: "Test Identifier")
    }
}
