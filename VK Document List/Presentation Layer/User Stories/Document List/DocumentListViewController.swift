//
//  DocumentListViewController.swift
//  VK Document List
//
//  Created by Vladislav on 23.02.2020.
//  Copyright © 2020 Vladislav Markov. All rights reserved.
//

import UIKit

class DocumentListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Props
    var viewModel: DocumentListViewModel?
    var router: DocumentListRouterInput?
    
    private var cellModels: [TableCellModel] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupComponents()
        setupActions()
    }
    
    override func viewDidLayoutSubviews() {
        applyStyles()
    }
    
    // MARK: - Public functions
    public func renameDocumentItem(with documentItem: DocumentItem) {
        viewModel?.renameItem(with: documentItem, completion: { [weak self] (result) in
            self?.loadDataResult(result)
        })
    }
    
    public func deleteDocumentItem(with documentItem: DocumentItem) {
        viewModel?.deleteItem(with: documentItem, completion: { [weak self] (result) in
            self?.loadDataResult(result)
        })
    }
    
}

// MARK: - Setup functions
extension DocumentListViewController {
    
    func setupComponents() {
        navigationItem.title = "DocumentListTitle".localized
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerCellNib(DocumentItemTableCell.self)
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        reloadData()
    }
    
    func setupActions() { }
    
    func applyStyles() { }
    
}

// MARK: - Actions
extension DocumentListViewController {
    
    @objc
    private func reloadData() {
        viewModel?.reloadData(completion: { [weak self] (result) in
            self?.loadDataResult(result)
        })
    }
    
}

// MARK: - Module functions
extension DocumentListViewController {
    
    private func loadDataResult(_ result: Result<[TableCellModel], DocumentListError>) {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
        switch result {
        case let .success(cellModels):
            self.cellModels = cellModels
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        case let .failure(error):
            switch error {
            case .unknown,
                 .noInternetConnection:
                router?.showError(error)
            default:
                break
            }
        }
    }
    
}

// MARK: - UITableViewDataSource
extension DocumentListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = cellModels[indexPath.row]
        
        if model is DocumentItemCellModel {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier) as? DocumentItemTableCell else { return UITableViewCell() }
            cell.model = model
            cell.output = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellModels[indexPath.row].cellHeight
    }
    
}

// MARK: - UITableViewDelegate
extension DocumentListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = cellModels[indexPath.row] as? DocumentItemCellModel else { return }
        router?.pushSafariViewController(with: model.documentItem)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging
            && !cellModels.isEmpty
            && indexPath.row == cellModels.count - 1 {
            viewModel?.loadNextData(completion: { [weak self] (result) in
                self?.loadDataResult(result)
            })
        }
    }
    
}

// MARK: - DocumentItemTableCellOutput
extension DocumentListViewController: DocumentItemTableCellOutput {
    
    func documentItemMoreButtonPressed(with documentItem: DocumentItem) {
        router?.showDocumentItemMenu(with: documentItem)
    }
    
}
