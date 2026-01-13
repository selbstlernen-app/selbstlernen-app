//
//  TimerCountdownLiveActivity.swift
//  TimerCountdown
//
//  Created by Madeleine on 12.01.26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState // don't forget to add this line, otherwise, live activity will not display it.

  public struct ContentState: Codable, Hashable {}

    var id = UUID()
}

let sharedDefault = UserDefaults(suiteName: "group.com.masterthesis.srl.app")!

struct TimerCountdownLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            
            let name = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Loading..."
               
               
            let endTime =  Date(timeIntervalSince1970: sharedDefault.double(forKey: context.attributes.prefixedKey("endTime")) / 1000)
            
            
            // Lock screen/banner UI goes here
            VStack {
                HStack {
                    Text(name)
                        .font(.headline)
                    Spacer()
                    Text(timerInterval: Date.now...endTime, countsDown: true)
                        .monospacedDigit()
                        .font(.title2)
                }
            }
            .padding()
            
        } dynamicIsland: { context in
            let name = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Loading..."
            let endTime =  Date(timeIntervalSince1970: sharedDefault.double(forKey: context.attributes.prefixedKey("endTime")) / 1000)
            
            return DynamicIsland {
                // Expanded UI (when long-pressed)
                DynamicIslandExpandedRegion(.leading) {
                    Text(name)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date.now...endTime, countsDown: true)
                }
            } compactLeading: {
                Text("🍕")
            } compactTrailing: {
                Text(timerInterval: Date.now...endTime, countsDown: true)
                    .frame(width: 45)
            } minimal: {
                Text("⏳")
            }
        }
    }
}


extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}
