//
//  DemoWidget.swift
//  DemoWidget
//
//  Created by Maman Khan on 01/08/2024.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), state: "ready", post: nil, configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), state: "ready", post:nil, configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        do {
            print("Calling again")

            let items = try await DataService.shared.fetchData()


                var entries: [SimpleEntry] = []

                // Generate a timeline consisting of five entries an hour apart, starting from the current date.
                let currentDate = Date()
                for hourOffset in 0 ..< 3 {
                    let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset * 5, to: currentDate)!
                    let entry = SimpleEntry(date: entryDate, state: "ready", post: items[hourOffset] ,configuration: configuration)
                    entries.append(entry)
                }

            return Timeline(entries: entries, policy: .atEnd)
        } catch {
            print("❌ Error - \(error)")

            
            let entry = SimpleEntry(
                date: Date().advanced(by: -86400), state: "error", post: nil, configuration: ConfigurationAppIntent()
            )

            return Timeline(entries: [entry], policy: .atEnd)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let state: String
    let post: Posts?
    let configuration: ConfigurationAppIntent
}

struct DemoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)
            
            Text("STATE:" + entry.state)

            Text("Favorite Emoji:")
            Text(entry.post?.title ?? "NO post")
        }
    }
}

struct DemoWidget: Widget {
    let kind: String = "DemoWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            DemoWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    DemoWidget()
} timeline: {
    SimpleEntry(date: .now, state: "ready", post: nil, configuration: .smiley)
    SimpleEntry(date: .now, state: "ready", post: nil, configuration: .starEyes)
}
