//
//  DetailView.swift
//  lucid-demo2
//
//  Created by Jack Belding on 7/26/23.
//

import SwiftUI

struct DetailView: View {
    let entity: MyEntity

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                DetailCellView(label: "Remote Value", value: "\(entity.identifier.value.remoteValue)")
                DetailCellView(label: "My Bool Property", value: "\(entity.myBoolProperty)")
                DetailCellView(label: "My String Property", value: entity.myStringProperty)
            }
            .padding()
        }
        .navigationTitle("Detail View")
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(entity: testData1)
//    }
//}
