//
//  Diary - DiaryViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreData

final class DiaryViewController: UIViewController {
    private var tableView: UITableView = UITableView()
    private var diaryList: [Diary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDiary()
    }
}

extension DiaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let diary = diaryList[indexPath.row]
        let diaryDetailViewController = DiaryDetailViewController(
            diary: diary,
            title: diary.value(forKeyPath: "title") as? String ?? "",
            body: diary.value(forKeyPath: "body") as? String ?? "",
            date: diary.value(forKeyPath: "date") as? Date ?? Date()
        )
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(diaryDetailViewController, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "삭제") { _, _, _ in
            let diary = self.diaryList[indexPath.row]
            self.diaryList.remove(at: indexPath.row)
            self.deleteDiary(item: diary)
            tableView.reloadData()
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension DiaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.basic) as? DiaryCell else {
            return UITableViewCell()
        }
        
        let diary = diaryList[indexPath.row]
        let date = diary.value(forKeyPath: "date") as? Date ?? Date()
        let formattedDate = DateFormatter.diaryFormatter.string(from: date)
        
        cell.configureCell(
            title: diary.value(forKeyPath: "title") as? String ?? "",
            date: formattedDate,
            preview: diary.value(forKeyPath: "body") as? String ?? ""
        )
        
        return cell
    }
}

private extension DiaryViewController {
    func loadDiary() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Diary>(entityName: "Diary")
        
        do {
            diaryList = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            let alert = UIAlertController(title: nil, message: "Diary Data를 불러오지 못했습니다.", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .default)
            
            alert.addAction(action)
            present(alert, animated: true)
        }
    }
    
    func deleteDiary(item: Diary) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(item)
        
        do {
            try managedContext.save()
        } catch {
            print("error")
        }
    }
}

private extension DiaryViewController {
    func configure() {
        configureRootView()
        configureNavigation()
        configureTableView()
        registerCell()
        configureSubviews()
        configureConstraints()
    }
    
    func configureRootView() {
        view.backgroundColor = .systemBackground
    }
    
    func configureNavigation() {
        let action = UIAction { _ in
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let managedContext = appDelegate.persistentContainer.viewContext
            let diaryDetailViewController = DiaryDetailViewController(diary: Diary(context: managedContext))
            self.navigationController?.pushViewController(diaryDetailViewController, animated: true)
        }
        
        navigationItem.title = "일기장"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: action)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func registerCell() {
        tableView.register(DiaryCell.self, forCellReuseIdentifier: CellIdentifier.basic)
    }
    
    func configureSubviews() {
        view.addSubview(tableView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
