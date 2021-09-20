//
//  ContentView.swift
//  Demo
//
//  Created by nori on 2021/09/20.
//

import SwiftUI
import Carousel

struct ContentView: View {

    @State var selection: String = "a"

    var body: some View {
        Carousel(["a", "b", "c", "d", "e", "f"], id: \.self, selection: $selection) { data in
            VStack {
                Text(data)
                    .font(.system(size: 40))
                    .background(Color.red)
                Button("+") {
                    self.selection = "c"
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
