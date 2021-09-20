//
//  Carousel.swift
//  
//
//  Created by nori on 2021/09/20.
//

import SwiftUI


public struct Carousel<Data, ID, Content> where Data : RandomAccessCollection, ID : Hashable {

    @State var index: Int?

    @State var isTapped: Bool = false

    public var selection: Binding<ID>?

    public var data: Data

    var id: KeyPath<Data.Element, ID>

    public var content: (Data.Element) -> Content
}

extension Carousel where ID == Data.Element.ID, Content : View, Data.Element : Identifiable {

    public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self._index = State(initialValue: data.isEmpty ? nil : 0)
        self.data = data
        self.id = \Data.Element.id
        self.content = content
    }

    public init(_ data: Data, selection: Binding<ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        let index = data.map(\.id).firstIndex(of: selection.wrappedValue)
        self._index = State(initialValue: index)
        self.selection = selection
        self.data = data
        self.id = \Data.Element.id
        self.content = content
    }
}

extension Carousel where Content : View {

    public init(_ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self._index = State(initialValue: data.isEmpty ? nil : 0)
        self.data = data
        self.id = id
        self.content = content
    }

    public init(_ data: Data, id: KeyPath<Data.Element, ID>, selection: Binding<ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        let index = data.map({ $0[keyPath: id] }).firstIndex(of: selection.wrappedValue)
        self._index = State(initialValue: index)
        self.selection = selection
        self.data = data
        self.id = id
        self.content = content
    }
}

extension Carousel: View where Content: View {

    @ViewBuilder
    var selectionContent: some View {
        if let index = self.index {
            let element = Array(data)[index]
            content(element)
        } else {
            EmptyView()
        }
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                self.isTapped = true
            }
            .onEnded { _ in
                self.isTapped = false
            }
    }

    public var body: some View {
        ZStack {
            if let index = index {
                HStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 64)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.index? -= 1
                        }
                        .disabled(0 == index)
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.index? += 1
                        }
                        .disabled(index == data.count - 1)
                }
            }
            selectionContent
            if let index = self.index {
                VStack {
                    Indicator(data.count, selection: $index, stop: isTapped) {
                        if index < data.count - 1 {
                            self.index? += 1
                        }
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .onChange(of: index) { newValue in
            if let index = newValue {
                self.selection?.wrappedValue = Array(data)[index][keyPath: id]
            }
        }
        .onChange(of: selection?.wrappedValue) { newValue in
            if let selection = newValue {
                let index = data.map({ $0[keyPath: id] }).firstIndex(of: selection)
                if self.index != index {
                    self.index = index
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(dragGesture)
    }
}

struct Carousel_Previews: PreviewProvider {

    struct ContentView: View {

        @State var selection: String = "a"

        var body: some View {
            Carousel(["a", "b", "c", "d", "e", "f"], id: \.self, selection: $selection) { data in
                VStack {
                    Text(data)
                        .font(.system(size: 40))
                        .background(Color.red)
                }
            }
        }
    }

    static var previews: some View {
        ContentView()
    }
}
