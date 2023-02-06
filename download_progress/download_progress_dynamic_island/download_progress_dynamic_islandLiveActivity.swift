//
//  download_progress_dynamic_islandLiveActivity.swift
//  download_progress_dynamic_island
//
//  Created by Leo Nugraha on 2023/2/6.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DownloadProgressAttributes: ActivityAttributes {

    public struct ContentState: Codable, Hashable {
        var percentProgress: Double
        var downloadProgress: Double
    }

    var totalFileSize: Double
}

struct download_progress_dynamic_islandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DownloadProgressAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Downloaded Percentage: \(Int(context.state.percentProgress))%")
                    .bold()

                ProgressView(value: context.state.percentProgress * 0.01)
                    .padding([.leading, .trailing], 30)
                    .accentColor(.orange)
                    .scaleEffect(x: 1, y: 3, anchor: .center)

            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("\(Int(context.state.percentProgress))%")
                        .padding([.leading], 30)

                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.downloadProgress * 0.000_001)) MB")
                        .padding([.trailing], 30)

                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: (context.state.percentProgress * 0.01))
                        .padding([.leading, .trailing], 30)
                        .accentColor(.orange)
                        .scaleEffect(x: 1, y: 3, anchor: .center)

                }
            } compactLeading: {
                Text("\(Int(context.state.percentProgress))%")
                
            } compactTrailing: {
                Text("\(Int(context.state.downloadProgress * 0.000_001)) MB")

            } minimal: {
                Text("\(Int(context.state.percentProgress)) %")
                    .font(.system(size: 9))
                    .bold()
            }
        }
    }
}

// MARK: Preview Purpose (just for example)
struct download_progress_dynamic_islandLiveActivity_Previews: PreviewProvider {
    static let attributes = DownloadProgressAttributes(totalFileSize: 1000)
    static let contentState = DownloadProgressAttributes.ContentState(percentProgress: 80, downloadProgress: 0.0)

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
