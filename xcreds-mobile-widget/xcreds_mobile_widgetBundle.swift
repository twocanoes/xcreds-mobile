//
//  xcreds_mobile_widgetBundle.swift
//  xcreds-mobile-widget
//
//  Created by Timothy Perfitt on 3/17/26.
//

import WidgetKit
import SwiftUI

@main
struct xcreds_mobile_widgetBundle: WidgetBundle {
    var body: some Widget {
        xcreds_mobile_widget()
        xcreds_mobile_widgetControl()
        xcreds_mobile_widgetLiveActivity()
    }
}
