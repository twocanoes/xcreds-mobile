//
//  xcreds_mobile_widgetLiveActivity.swift
//  xcreds-mobile-widget
//
//  Created by Timothy Perfitt on 3/17/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct xcreds_mobile_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct xcreds_mobile_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: xcreds_mobile_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension xcreds_mobile_widgetAttributes {
    fileprivate static var preview: xcreds_mobile_widgetAttributes {
        xcreds_mobile_widgetAttributes(name: "World")
    }
}

extension xcreds_mobile_widgetAttributes.ContentState {
    fileprivate static var smiley: xcreds_mobile_widgetAttributes.ContentState {
        xcreds_mobile_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: xcreds_mobile_widgetAttributes.ContentState {
         xcreds_mobile_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: xcreds_mobile_widgetAttributes.preview) {
   xcreds_mobile_widgetLiveActivity()
} contentStates: {
    xcreds_mobile_widgetAttributes.ContentState.smiley
    xcreds_mobile_widgetAttributes.ContentState.starEyes
}
