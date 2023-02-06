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
        var percentProgress: Double // How many percents have been downloaded
        var downloadProgress: Double // How much data have been downloaded
    }

    var totalFileSize: Double // Fixed and unchanged
}

struct download_progress_dynamic_islandLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DownloadProgressAttributes.self) { context in

            VStack {
                Text("Download Percentage: \(Int(context.state.percentProgress))%")
                    .bold()

                ProgressView(value: context.state.percentProgress * 0.01)
                    .padding([.leading, .trailing], 30)
                    .accentColor(.orange)
                    .scaleEffect(x: 1, y: 3, anchor: .center)
                
            }
            // .activityBackgroundTint(Color.purple.opacity(0.6))
            // .activitySystemActionForegroundColor(Color.black)
            
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
                ZStack {
                    RingShape()
                        .stroke(style: StrokeStyle(lineWidth: 3))
                        .fill(Color.orange.opacity(0.5))
                    RingShape(percent: context.state.percentProgress)
                        .stroke(style: StrokeStyle(lineWidth: 3,
                                                   lineCap: .round))
                        .fill(Color.orange)
                }
                .animation(Animation.easeIn)

            }
        }
    }
    
    struct RingShape: Shape {
        
        var percent: Double
        let startAngle: Double
        
        typealias AnimatableData = Double
        var animatableData: Double {
            get {
                return percent
            }
            
            set {
                percent = newValue
            }
        }
        
        init(percent: Double = 100,
             startAngle: Double = -90) {
            self.percent = percent
            self.startAngle = startAngle
        }
        
        static func percentToAngle(percent: Double,
                                   startAngle: Double) -> Double {
            return (percent / 100 * 360) + startAngle
        }
        
        @available(iOS 13.0, *)
        public func path(in rect: CGRect) -> Path {
            let width    = rect.width
            let height   = rect.height
            let radius   = min(height, width) / 2
            let center   = CGPoint(x: width/2, y: height/2)
            let endAngle = Self.percentToAngle(percent: percent,
                                               startAngle: startAngle)
            return Path { path in path.addArc(center: center,
                                              radius: radius,
                                              startAngle: Angle(degrees: startAngle),
                                              endAngle: Angle(degrees: endAngle),
                                              clockwise: false)
            }
        }
        
    }
    
    // MARK: Preview Purpose (just for example)
    struct download_progress_dynamic_islandLiveActivity_Previews: PreviewProvider {
        static let attributes = DownloadProgressAttributes(totalFileSize: 1000)
        static let contentState = DownloadProgressAttributes
            .ContentState(percentProgress: 65,
                          downloadProgress: 0.0)
        
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
}
