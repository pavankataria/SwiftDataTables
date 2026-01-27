//
//  LiveTextEditingDemoViewController.swift
//  SwiftDataTables
//
//  Created by Pavan Kataria on 22/02/2017.
//  Copyright © 2016-2026 Pavan Kataria. All rights reserved.
//

import UIKit
import SwiftDataTables

/// Demo showing live row height updates during text editing.
/// Each row has an editable text view - as you type, the row height
/// smoothly adjusts to fit the content.
final class LiveTextEditingDemoViewController: UIViewController {

    // MARK: - Model

    struct EditableNote: Identifiable {
        let id: String
        var title: String
        var content: String
        let createdAt: Date

        var dateString: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: createdAt)
        }
    }

    // MARK: - State

    private var dataTable: SwiftDataTable!
    private var notes: [EditableNote] = []
    private var controls: ExplanationControls!
    private var pendingUpdateWorkItem: DispatchWorkItem?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Live Text Editing"
        view.backgroundColor = .systemBackground

        controls = makeExplanationControls()
        installExplanation(controls.view)

        setupInitialData()
        setupTable()

        // Keyboard handling
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupInitialData() {
        notes = [
            EditableNote(id: "1", title: "Welcome", content: "Tap here to edit this text. As you type more, the row will grow taller to fit your content.", createdAt: Date()),
            EditableNote(id: "2", title: "Shopping List", content: "Milk\nBread\nEggs", createdAt: Date().addingTimeInterval(-3600)),
            EditableNote(id: "3", title: "Ideas", content: "Try typing a lot of text to see how smoothly the row height adjusts!", createdAt: Date().addingTimeInterval(-7200)),
            EditableNote(id: "4", title: "Quick Note", content: "Short.", createdAt: Date().addingTimeInterval(-10800)),
            EditableNote(id: "5", title: "Meeting Notes", content: "Discussed project timeline and deliverables. Need to follow up on:\n- Budget approval\n- Resource allocation\n- Timeline adjustments", createdAt: Date().addingTimeInterval(-14400)),
        ]
    }

    private func setupTable() {
        var config = DataTableConfiguration()
        config.shouldShowSearchSection = false
        config.textLayout = .wrap
        config.rowHeightMode = .automatic(estimated: 80)

        // Custom cells with editable text views
        config.cellSizingMode = .autoLayout(provider: DataTableCustomCellProvider(
            register: { collectionView in
                collectionView.register(EditableTextCell.self, forCellWithReuseIdentifier: "EditableCell")
                collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "StaticCell")
            },
            reuseIdentifierFor: { indexPath in
                indexPath.item == 1 ? "EditableCell" : "StaticCell"
            },
            configure: { [weak self] cell, value, indexPath in
                guard let self = self else { return }

                if let editableCell = cell as? EditableTextCell {
                    // Content column - editable
                    editableCell.textView.text = value.stringRepresentation
                    editableCell.rowIndex = indexPath.section
                    editableCell.delegate = self
                } else {
                    // Title/Date columns - static label
                    let label = cell.contentView.viewWithTag(100) as? UILabel ?? {
                        let l = UILabel()
                        l.tag = 100
                        l.translatesAutoresizingMaskIntoConstraints = false
                        l.numberOfLines = 0
                        l.font = .systemFont(ofSize: 14)
                        cell.contentView.addSubview(l)
                        NSLayoutConstraint.activate([
                            l.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                            l.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 8),
                            l.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -8),
                            l.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),
                        ])
                        return l
                    }()
                    label.text = value.stringRepresentation
                    label.font = indexPath.item == 0
                        ? .systemFont(ofSize: 15, weight: .semibold)
                        : .systemFont(ofSize: 12, weight: .regular)
                    label.textColor = indexPath.item == 0 ? .label : .secondaryLabel
                }
            },
            sizingCellFor: { reuseId in
                reuseId == "EditableCell" ? EditableTextCell() : UICollectionViewCell()
            }
        ))

        let columns: [DataTableColumn<EditableNote>] = [
            .init("Title", \.title),
            .init("Content", \.content),
            .init("Created", \.dateString),
        ]

        let table = SwiftDataTable(data: notes, columns: columns, options: config)
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: controls.view.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        dataTable = table
        updateNoteCountLabel()
    }

    // MARK: - Actions

    @objc func addNote() {
        let newNote = EditableNote(
            id: UUID().uuidString,
            title: "Note \(notes.count + 1)",
            content: "New note - tap to edit",
            createdAt: Date()
        )
        notes.insert(newNote, at: 0)
        dataTable.setData(notes, animatingDifferences: true)
        updateNoteCountLabel()
        log("Added new note")
    }

    @objc func deleteFirst() {
        guard !notes.isEmpty else { return }
        notes.removeFirst()
        dataTable.setData(notes, animatingDifferences: true)
        updateNoteCountLabel()
        log("Deleted first note")
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Keyboard

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom
        dataTable.collectionView.contentInset.bottom = bottomInset
        dataTable.collectionView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        dataTable.collectionView.contentInset.bottom = 0
        dataTable.collectionView.verticalScrollIndicatorInsets.bottom = 0
    }

    // MARK: - Helpers

    private func updateNoteCountLabel() {
        controls.noteCountLabel.text = "Notes: \(notes.count)"
    }

    private func log(_ message: String) {
        controls.logLabel.text = message
    }
}

// MARK: - EditableTextCellDelegate

extension LiveTextEditingDemoViewController: EditableTextCellDelegate {
    func editableTextCell(_ cell: EditableTextCell, didChangeText text: String, forRowAt index: Int) {
        guard index < notes.count else { return }
        notes[index].content = text

        // Cancel any pending update
        pendingUpdateWorkItem?.cancel()

        // Debounce: wait briefly for fast typing before triggering height recalculation
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            // Remeasure just this row - no cell reload, preserves keyboard focus
            let heightChanged = self.dataTable.remeasureRow(index)

            let charCount = text.count
            self.log("Row \(index): \(charCount) chars" + (heightChanged ? " (height updated)" : ""))
        }
        pendingUpdateWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
}

// MARK: - EditableTextCellDelegate Protocol

protocol EditableTextCellDelegate: AnyObject {
    func editableTextCell(_ cell: EditableTextCell, didChangeText text: String, forRowAt index: Int)
}

// MARK: - Editable Text Cell

final class EditableTextCell: UICollectionViewCell, UITextViewDelegate {

    weak var delegate: EditableTextCellDelegate?
    var rowIndex: Int = 0

    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = .systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        tv.backgroundColor = .secondarySystemBackground
        tv.layer.cornerRadius = 6
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(textView)
        textView.delegate = self

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text = nil
        delegate = nil
        rowIndex = 0
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        delegate?.editableTextCell(self, didChangeText: textView.text, forRowAt: rowIndex)
    }
}
