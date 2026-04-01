import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), counters: 0, goalsReached: 0, progress: 0, level: 1, levelTitle: "Newbie")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), counters: 0, goalsReached: 0, progress: 0, level: 1, levelTitle: "Newbie")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Read data from UserDefaults (shared with Flutter app)
        let sharedDefaults = UserDefaults(suiteName: "group.com.twinam.app")
        
        let counters = sharedDefaults?.integer(forKey: "totalCounters") ?? 0
        let goalsReached = sharedDefaults?.integer(forKey: "goalsReached") ?? 0
        let progress = sharedDefaults?.integer(forKey: "todayProgress") ?? 0
        let level = sharedDefaults?.integer(forKey: "level") ?? 1
        let levelTitle = sharedDefaults?.string(forKey: "levelTitle") ?? "Newbie"
        
        let entry = SimpleEntry(
            date: Date(),
            counters: counters,
            goalsReached: goalsReached,
            progress: progress,
            level: level,
            levelTitle: levelTitle
        )
        
        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let counters: Int
    let goalsReached: Int
    let progress: Int
    let level: Int
    let levelTitle: String
}

struct TwinAmWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.18, green: 0.18, blue: 0.23),
                    Color(red: 0.10, green: 0.10, blue: 0.14)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text("Twin'Am")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Lvl \(entry.level)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 1.0, green: 0.72, blue: 0.30))
                        .cornerRadius(12)
                }
                
                // Progress
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.7))
                    
                    ProgressView(value: Double(entry.progress), total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.30, green: 0.69, blue: 0.31)))
                    
                    Text("\(entry.progress)%")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0.30, green: 0.69, blue: 0.31))
                }
                
                // Stats
                HStack(spacing: 20) {
                    VStack {
                        Text("\(entry.counters)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.13, green: 0.59, blue: 0.95))
                        Text("Counters")
                            .font(.system(size: 10))
                            .foregroundColor(Color(white: 0.7))
                    }
                    
                    VStack {
                        Text("\(entry.goalsReached)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.30, green: 0.69, blue: 0.31))
                        Text("Goals")
                            .font(.system(size: 10))
                            .foregroundColor(Color(white: 0.7))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
        }
    }
}

@main
struct TwinAmWidget: Widget {
    let kind: String = "TwinAmWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TwinAmWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Twin'Am")
        .description("View your counters and progress at a glance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TwinAmWidget_Previews: PreviewProvider {
    static var previews: some View {
        TwinAmWidgetEntryView(entry: SimpleEntry(date: Date(), counters: 5, goalsReached: 3, progress: 65, level: 3, levelTitle: "Apprentice"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
