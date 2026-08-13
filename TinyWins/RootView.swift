import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max.fill") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
        .tint(Brand.ink)
    }
}

private enum Brand {
    static let cream = Color(red: 0.98, green: 0.96, blue: 0.90)
    static let coral = Color(red: 0.96, green: 0.42, blue: 0.31)
    static let gold = Color(red: 0.96, green: 0.70, blue: 0.24)
    static let mint = Color(red: 0.42, green: 0.72, blue: 0.61)
    static let ink = Color(red: 0.12, green: 0.17, blue: 0.18)
}

private struct TodayView: View {
    @EnvironmentObject private var store: WinStore
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ZStack {
                Brand.cream.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 22) {
                        header
                        progressCard
                        winsList
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 110)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Button { showingAdd = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 62, height: 62)
                        .background(Brand.coral, in: Circle())
                        .shadow(color: Brand.coral.opacity(0.3), radius: 12, y: 7)
                }
                .accessibilityLabel("Add a win")
                .padding(24)
            }
            .sheet(isPresented: $showingAdd) { AddWinView() }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Brand.coral)
                    .textCase(.uppercase)
                Text("Notice the good.")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(Brand.ink)
            }
            Spacer()
            Image(systemName: "sparkles")
                .font(.title2.weight(.bold))
                .foregroundStyle(Brand.gold)
                .padding(12)
                .background(.white.opacity(0.8), in: Circle())
        }
        .padding(.top, 18)
    }

    private var progressCard: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle().stroke(.white.opacity(0.45), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: min(CGFloat(store.todayWins.count) / 3, 1))
                    .stroke(.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(store.todayWins.count)")
                    .font(.system(size: 27, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 5) {
                Text(store.todayWins.isEmpty ? "Your first win awaits" : "You’re building momentum")
                    .font(.headline)
                Text("Aim for three tiny wins today. Every bit of progress counts.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
            }
        }
        .foregroundStyle(.white)
        .padding(20)
        .background(
            LinearGradient(colors: [Brand.mint, Brand.mint.opacity(0.78)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 26, style: .continuous)
        )
    }

    @ViewBuilder private var winsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TODAY’S WINS")
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(Brand.ink.opacity(0.55))
                Spacer()
                if store.streak > 0 {
                    Label("\(store.streak) day streak", systemImage: "flame.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Brand.coral)
                }
            }

            if store.todayWins.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 38))
                        .foregroundStyle(Brand.gold)
                    Text("Small things belong here")
                        .font(.headline)
                    Text("Sent the email, took a walk, asked for help—tap + and give yourself credit.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            } else {
                ForEach(store.todayWins) { win in
                    WinRow(win: win)
                }
            }
        }
    }
}

private struct WinRow: View {
    @EnvironmentObject private var store: WinStore
    let win: Win

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark")
                .font(.caption.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Brand.gold, in: Circle())
            Text(win.text)
                .font(.body.weight(.semibold))
                .foregroundStyle(Brand.ink)
            Spacer()
            Text(win.createdAt, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(17)
        .background(.white, in: RoundedRectangle(cornerRadius: 19, style: .continuous))
        .contextMenu {
            Button(role: .destructive) { store.delete(win) } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

private struct AddWinView: View {
    @EnvironmentObject private var store: WinStore
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Brand.cream.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Brand.gold)
                    Text("What went right?")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(Brand.ink)
                    TextField("I finished…", text: $text, axis: .vertical)
                        .font(.title3.weight(.semibold))
                        .lineLimit(3...6)
                        .padding(18)
                        .background(.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .focused($isFocused)
                        .submitLabel(.done)
                    Text("Keep it simple. A win can be as small as starting.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        store.add(text)
                        dismiss()
                    } label: {
                        Text("Celebrate this win")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(17)
                            .foregroundStyle(.white)
                            .background(Brand.coral, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                }
                .padding(24)
            }
            .navigationTitle("New Win")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { isFocused = true }
        }
        .presentationDetents([.medium, .large])
    }
}

private struct HistoryView: View {
    @EnvironmentObject private var store: WinStore

    var body: some View {
        NavigationStack {
            ZStack {
                Brand.cream.ignoresSafeArea()
                if store.wins.isEmpty {
                    ContentUnavailableView("Your story starts today", systemImage: "book.closed", description: Text("Completed wins will collect here."))
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 22, pinnedViews: .sectionHeaders) {
                            ForEach(store.groupedWins, id: \.date) { group in
                                Section {
                                    ForEach(group.wins) { win in WinRow(win: win) }
                                } header: {
                                    Text(group.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                                        .font(.caption.weight(.bold))
                                        .tracking(0.8)
                                        .foregroundStyle(Brand.ink.opacity(0.65))
                                        .padding(.vertical, 6)
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Your Wins")
            .toolbarBackground(Brand.cream, for: .navigationBar)
        }
    }
}

#Preview {
    RootView().environmentObject(WinStore())
}
