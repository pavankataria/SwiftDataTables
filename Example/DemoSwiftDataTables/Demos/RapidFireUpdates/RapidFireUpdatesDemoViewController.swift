//
//  RapidFireUpdatesDemoViewController.swift
//  DemoSwiftDataTables
//
//  Demonstrates extremely fast row updates to stress test the update system.
//

import UIKit
import SwiftDataTables

/// Rapid-fire updates demo showing the table handling many updates per second.
/// Tests the efficiency of incremental height calculations and diffing.
final class RapidFireUpdatesDemoViewController: UIViewController {

    // MARK: - Model

    struct MessageItem: Identifiable {
        let id: String
        var sender: String
        var message: String
        var timestamp: Date
        var priority: Priority

        enum Priority: CaseIterable {
            case low, normal, high, urgent

            var color: UIColor {
                switch self {
                case .low: return .systemGray
                case .normal: return .label
                case .high: return .systemOrange
                case .urgent: return .systemRed
                }
            }

            var name: String {
                switch self {
                case .low: return "Low"
                case .normal: return "Normal"
                case .high: return "High"
                case .urgent: return "URGENT"
                }
            }
        }

        var timeString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter.string(from: timestamp)
        }
    }

    // MARK: - Message Content

    private let senders = ["Alice", "Bob", "Carol", "Dave", "Eve", "Frank", "Grace", "Henry"]

    private let shortMessages = [
        "OK", "Got it", "Thanks!", "Yes", "No", "Maybe", "Sure", "Done",
    ]

    private let mediumMessages = [
        "I'll check and get back to you",
        "Can we discuss this later?",
        "Please review the attached",
        "Meeting scheduled for tomorrow",
        "Update: Task completed successfully",
    ]

    private let longMessages = [
        "This is an important update that requires your immediate attention. Please review all the details carefully before proceeding with any action.",
        "Just wanted to follow up on our earlier conversation about the project timeline. We need to make some adjustments based on the latest feedback from the stakeholders.",
        "Quick reminder: The deadline for the quarterly report submission is approaching. Make sure all sections are completed and reviewed by end of day.",
    ]

    // MARK: - State

    private var dataTable: SwiftDataTable!
    private var messages: [MessageItem] = []
    private var updateTimer: Timer?
    private var messageIdCounter = 0
    private var updateCount = 0
    private var updatesPerSecond: Double = 0
    private var lastSecondUpdates = 0
    private var fpsTimer: Timer?
    private var controls: ExplanationControls!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Rapid-Fire Updates"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        setupInitialData()
        setupTable()
        startFPSTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        fpsTimer?.invalidate()
    }

    deinit {
        stopTimer()
        fpsTimer?.invalidate()
    }

    // MARK: - Setup

    private func setupInitialData() {
        // Start with some messages
        for i in 0..<10 {
            messages.append(createMessage(index: i))
        }
    }

    private func createMessage(index: Int) -> MessageItem {
        messageIdCounter += 1
        let messageType = Int.random(in: 0...10)
        let message: String
        if messageType < 5 {
            message = shortMessages.randomElement()!
        } else if messageType < 8 {
            message = mediumMessages.randomElement()!
        } else {
            message = longMessages.randomElement()!
        }

        return MessageItem(
            id: "msg-\(messageIdCounter)",
            sender: senders.randomElement()!,
            message: message,
            timestamp: Date(),
            priority: MessageItem.Priority.allCases.randomElement()!
        )
    }

    private func setupTable() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        config.textLayout = .wrap
        config.rowHeightMode = .automatic(estimated: 50)

        config.cellSizingMode = .autoLayout(provider: DataTableCustomCellProvider(
            register: { collectionView in
                collectionView.register(MessageCell.self, forCellWithReuseIdentifier: "MsgCell")
            },
            reuseIdentifierFor: { _ in "MsgCell" },
            configure: { [weak self] cell, value, indexPath in
                guard let self = self,
                      let msgCell = cell as? MessageCell,
                      indexPath.section < self.messages.count else { return }

                let item = self.messages[indexPath.section]
                msgCell.label.text = value.stringRepresentation

                // Style based on column
                switch indexPath.item {
                case 0: // Sender
                    msgCell.label.font = .systemFont(ofSize: 13, weight: .bold)
                    msgCell.label.textColor = .label
                    msgCell.label.numberOfLines = 1
                case 1: // Message
                    msgCell.label.font = .systemFont(ofSize: 13)
                    msgCell.label.textColor = .label
                    msgCell.label.numberOfLines = 0
                case 2: // Priority
                    msgCell.label.font = .systemFont(ofSize: 11, weight: .semibold)
                    msgCell.label.textColor = item.priority.color
                    msgCell.label.numberOfLines = 1
                case 3: // Time
                    msgCell.label.font = .monospacedDigitSystemFont(ofSize: 10, weight: .regular)
                    msgCell.label.textColor = .secondaryLabel
                    msgCell.label.numberOfLines = 1
                default:
                    break
                }
            },
            sizingCellFor: { _ in MessageCell() }
        ))

        let columns: [DataTableColumn<MessageItem>] = [
            .init("From", \.sender),
            .init("Message", \.message),
            .init("Priority") { .string($0.priority.name) },
            .init("Time", \.timeString),
        ]

        let table = SwiftDataTable(data: messages, columns: columns, options: config)
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controls.view.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
        updateStats()
    }

    // MARK: - Timer

    private func startFPSTimer() {
        fpsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updatesPerSecond = Double(self.updateCount - self.lastSecondUpdates)
            self.lastSecondUpdates = self.updateCount
            self.controls.upsLabel.text = String(format: "%.0f/sec", self.updatesPerSecond)
        }
    }

    private func startTimer() {
        guard controls.runningSwitch.isOn else { return }
        let interval = 1.0 / Double(controls.rateSlider.value)
        updateTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.performUpdate()
        }
    }

    private func stopTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func restartTimer() {
        stopTimer()
        startTimer()
    }

    // MARK: - Actions

    @objc func runningToggled(_ sender: UISwitch) {
        if sender.isOn {
            startTimer()
            log("Started rapid updates")
        } else {
            stopTimer()
            log("Stopped")
        }
    }

    @objc func rateChanged(_ sender: UISlider) {
        let rate = Int(sender.value)
        controls.rateValueLabel.text = "\(rate)/s"
        if controls.runningSwitch.isOn {
            restartTimer()
        }
    }

    @objc func addBurst() {
        // Add 10 messages rapidly
        for _ in 0..<10 {
            messages.insert(createMessage(index: messages.count), at: 0)
        }
        dataTable.setData(messages, animatingDifferences: true)
        updateCount += 10
        updateStats()
        log("Burst: +10 messages")
    }

    @objc func clearAll() {
        messages.removeAll()
        dataTable.setData(messages, animatingDifferences: true)
        updateStats()
        log("Cleared all")
    }

    // MARK: - Updates

    private func performUpdate() {
        let action = Int.random(in: 0...10)

        switch action {
        case 0...3: // Add new message
            messages.insert(createMessage(index: messages.count), at: 0)
            // Keep max 50 messages
            if messages.count > 50 {
                messages.removeLast()
            }

        case 4...6: // Update random message
            if !messages.isEmpty {
                let idx = Int.random(in: 0..<messages.count)
                messages[idx].message = [shortMessages, mediumMessages, longMessages].randomElement()!.randomElement()!
                messages[idx].timestamp = Date()
            }

        case 7...8: // Change priority
            if !messages.isEmpty {
                let idx = Int.random(in: 0..<messages.count)
                messages[idx].priority = MessageItem.Priority.allCases.randomElement()!
            }

        default: // Delete oldest if > 20
            if messages.count > 20 {
                messages.removeLast()
            } else if !messages.isEmpty {
                let idx = Int.random(in: 0..<messages.count)
                messages[idx].message = shortMessages.randomElement()!
            }
        }

        updateCount += 1
        dataTable.setData(messages, animatingDifferences: true)
        updateStats()
    }

    private func updateStats() {
        controls.messageCountLabel.text = "Msgs: \(messages.count)"
        controls.updateCountLabel.text = "Total: \(updateCount)"
    }

    private func log(_ message: String) {
        controls.logLabel.text = message
    }
}

// MARK: - Message Cell

private final class MessageCell: UICollectionViewCell {

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 13)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        label.font = .systemFont(ofSize: 13)
        label.textColor = .label
        label.numberOfLines = 0
    }
}
