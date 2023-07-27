//
//  MainView.swift
//  lucid-demo2
//
//  Created by Jack Belding on 7/26/23.
//

import SwiftUI

struct MainView: View {
    
    static let testData1: MyEntity = {
            let jsonString = """
                {
                    "identifier": 1,
                    "value": {
                        "localValue": "testID1",
                        "remoteValue": 1,
                    },
                    "myBoolProperty": true,
                    "myStringProperty": "Test String 1"
                }
            """
            let jsonData = jsonString.data(using: .utf8)!
            let decoder = JSONDecoder()

            // Decode the MyEntity object
            let testData1 = try! decoder.decode(MyEntity.self, from: jsonData)
            return testData1
        }()

    static let testData2: MyEntity = {
        let jsonString = """
            {
                "identifier": 2,
                "myBoolProperty": false,
                "myStringProperty": "Test String 2"
            }
        """
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        // Decode the MyEntity object
        let testData2 = try! decoder.decode(MyEntity.self, from: jsonData)
        return testData2
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    NavigationLink(destination: DetailView(entity: MainView.testData1)) {
                        MainTableCellView(identifier: MainView.testData1.myStringProperty)
                    }
                    
                    NavigationLink(destination: DetailView(entity: MainView.testData2)) {
                        MainTableCellView(identifier: MainView.testData2.myStringProperty)
                    }
                }
                .padding()
            }
            .navigationTitle("Main View")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

