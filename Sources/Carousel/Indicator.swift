//
//  Indicator.swift
//  
//
//  Created by nori on 2021/09/20.
//

import SwiftUI

struct Indicator: View {

    class Model: ObservableObject {
        var frameCount: Int = 0
        var date: Date = Date()
        @Published var isCompleted: Bool = false
    }

    @StateObject var model: Model = Model()

    @Binding var selection: Int?

    var count: Int

    var stop: Bool

    var interaval: TimeInterval

    var frameRate: TimeInterval = 60

    var action: () -> Void

    init(_ count: Int, selection: Binding<Int?>, stop: Bool, interval: TimeInterval = 6, action: @escaping () -> Void) {
        self.count = count
        self._selection = selection
        self.stop = stop
        self.interaval = interval
        self.action = action
    }

    var body: some View {
        HStack(spacing: 4) {
            if let selection = self.selection {
                ForEach(0..<count) { index in
                    if index == selection {
                        TimelineView(.periodic(from: Date(), by: 1 / frameRate)) { timeline in
                            ZStack {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.25))
                                IndicatorComponent(date: timeline.date, frameRate: frameRate, maximumTimeInterval: interaval, stop: stop, action: action)
                                    .onAppear {
                                        model.frameCount = 0
                                        model.date = timeline.date
                                    }
                            }
                        }
                    } else if index < selection {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                    } else {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.25))
                    }
                }
            } else {
                EmptyView()
            }
        }
        .frame(height: 3)
        .environmentObject(model)
        .onChange(of: selection) { _ in
            DispatchQueue.main.async {
                model.isCompleted = false
            }
        }
    }
}

struct IndicatorComponent: View {

    @EnvironmentObject var model: Indicator.Model

    var date: Date
    var frameRate: TimeInterval
    var maximumTimeInterval: TimeInterval
    var stop: Bool
    var action: () -> Void

    init(date: Date, frameRate: TimeInterval, maximumTimeInterval: TimeInterval, stop: Bool, action: @escaping () -> Void) {
        self.date = date
        self.frameRate = frameRate
        self.maximumTimeInterval = maximumTimeInterval
        self.stop = stop
        self.action = action
    }

    var progress: CGFloat {
        CGFloat(CGFloat(model.frameCount) / (frameRate * maximumTimeInterval))
    }

    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white)
                .frame(width: proxy.size.width * progress)
                .onChange(of: date) { newValue in
                    if !stop {
                        model.frameCount += 1
                    }
                    if 1 <= progress, !model.isCompleted {
                        model.isCompleted = true
                    }
                }
                .onChange(of: model.isCompleted) { isCompleted in
                    if isCompleted {
                        DispatchQueue.main.async {
                            action()
                        }
                    }
                }
        }
    }
}

struct Indicator_Previews: PreviewProvider {

    struct ContentView: View {

        @State var selection: Int? = 0

        @State var stop: Bool = false

        var body: some View {
            Indicator(5, selection: $selection, stop: stop) {
                selection? += 1
            }
                .padding()
                .background(Color.black)
        }
    }

    static var previews: some View {
        ContentView()
    }
}
