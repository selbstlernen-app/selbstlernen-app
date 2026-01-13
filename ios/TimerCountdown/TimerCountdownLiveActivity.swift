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
            HStack(alignment: .center, spacing: 12) {
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Mobile SRL")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.4)

                    Text(name)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .fixedSize(horizontal: true, vertical: false)

                Spacer(minLength: 20)

               
                Text(timerInterval: Date.now...endTime, countsDown: true)
                    .monospacedDigit()
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .contentTransition(.numericText())
                    .layoutPriority(1)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
          
        } dynamicIsland: { context in
            let name = sharedDefault.string(forKey: context.attributes.prefixedKey("name")) ?? "Loading..."
            let endTime =  Date(timeIntervalSince1970: sharedDefault.double(forKey: context.attributes.prefixedKey("endTime")) / 1000)
            
            return DynamicIsland {
                // Expanded UI (when long-pressed)
                DynamicIslandExpandedRegion(.leading) {
                                HStack {
                                    Image(systemName: "graduationcap.fill")
                                        .foregroundColor(.accentColor)
                                    Text("Mobile SRL")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 8)
                            }
                DynamicIslandExpandedRegion(.trailing) {
                                // Status badge
                                Text("Aktiv")
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(.trailing, 8)
                            }
                DynamicIslandExpandedRegion(.bottom) {
                                VStack(spacing: 12) {
                                    Text(name)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                    
                                    Text(timerInterval: Date.now...endTime, countsDown: true)
                                        .monospacedDigit()
                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                        .foregroundColor(.accentColor)
                                }
                                .padding(.bottom, 10)
                            }
            } compactLeading: {
                        // Icon changes based on content
                        Image(systemName: name.contains("Fokus") ? "brain.head.profile" : "cup.and.saucer.fill")
                            .foregroundColor(.accentColor)
                    } compactTrailing: {
                        Text(timerInterval: Date.now...endTime, countsDown: true)
                            .monospacedDigit()
                            .foregroundColor(.accentColor)
                            .frame(width: 45)
                    } minimal: {
                        Image(systemName: "timer")
                            .foregroundColor(.accentColor)
                    }
        }
    }
}


extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    return "\(id)_\(key)"
  }
}
