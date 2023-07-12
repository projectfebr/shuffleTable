//
//  ViewController.swift
//  shuffleTable
//
//  Created by Aleksandr Bolotov on 11.07.2023.
//

import UIKit

final class ViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var data: Array<State> = {
        let array = Array(1...30)
        return array.map { State(content: $0.description) }
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Task 4"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffleData))
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        view.addSubview(tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateLayout(with: view.bounds.size)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in
            self.updateLayout(with: size)
        }
    }
    
    private func updateLayout(with size: CGSize) {
        tableView.frame = CGRect(origin: .zero, size: size)
    }
    
    @objc
    private func shuffleData() {
        let shuffledData = data.shuffled()
        
        tableView.beginUpdates()
        
            for (currentRow, currentValue) in data.enumerated() {
                let toRow = shuffledData.firstIndex(of: currentValue) ?? 0
                tableView.moveRow(at: IndexPath(row: currentRow, section: 0), to: IndexPath(row: toRow, section: 0))
            }
        data = shuffledData
        
        tableView.endUpdates()
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        data[indexPath.row].isSelected.toggle()
        
        guard let  cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
        if cell.accessoryType == .checkmark {
            let value = data.remove(at: indexPath.row)
            data.insert(value, at: 0)
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.textLabel?.text = data[indexPath.row].content
        cell.accessoryType = data[indexPath.row].isSelected ? .checkmark : .none
        return cell
    }
}

class TableViewCell: UITableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
        textLabel?.text = ""
    }
}

struct State: Equatable {
    var content: String
    var isSelected: Bool = false
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.content == rhs.content
    }
}
