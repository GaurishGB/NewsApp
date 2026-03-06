//
//  ArticleDetailViewController.swift
//  NewsApp
//
//  Created by Gaurish Bandekar on 04/03/26.
//

import UIKit
import SafariServices

final class ArticleDetailViewController: UIViewController {
    
    private let viewModel: ArticleDetailViewModel
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let imageView = UIImageView()
    
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let contentLabel = UILabel()
//    private let descriptionLabel = UILabel()

    
    init(viewModel: ArticleDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Article"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavBar()
        setupViews()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBookmarkButton()
    }
    
    private func setupNavBar() {
        let shareItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )
        let bookmarkItem = UIBarButtonItem(
            image: UIImage(systemName: "bookmark"),
            style: .plain,
            target: self,
            action: #selector(didTapBookmark)
        )
        navigationItem.rightBarButtonItems = [shareItem, bookmarkItem]
    }
    
    private func setupViews() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0
        
        metaLabel.font = .preferredFont(forTextStyle: .subheadline)
        metaLabel.textColor = .secondaryLabel
        metaLabel.numberOfLines = 0
        
        contentLabel.font = .preferredFont(forTextStyle: .body)
        contentLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(metaLabel)
        stackView.addArrangedSubview(contentLabel)
        
        let openButton = UIButton(type: .system)
        openButton.setTitle("Open in Safari", for: .normal)
        openButton.addTarget(self, action: #selector(didTapOpenInSafari), for: .touchUpInside)
        
        stackView.addArrangedSubview(openButton)
    }
    
    private func configure() {
        
        let article = viewModel.article
        titleLabel.text = article.title
        
        var meta = article.source
        if let date = article.publishedAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            meta += " : \(formatter.string(from: date))"
        }
        
        metaLabel.text = meta
        
        contentLabel.text = article.content.isEmpty ? article.description : article.content
        
        if let url = article.imageURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data,
                      let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }.resume()
        }
    }
    
    private func updateBookmarkButton() {
        let isBookmarked = viewModel.isBookmarked
        let imageName = isBookmarked ? "bookmark.fill" : "bookmark"
        
        navigationItem.rightBarButtonItems?.last?.image = UIImage(systemName: imageName)
    }
    
    @objc private func didTapShare() {
        guard let url = viewModel.article.url else { return }
        
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activity, animated: true)
    }
    
    @objc private func didTapBookmark() {
        viewModel.toggleBookmark()
        updateBookmarkButton()
    }
    
    @objc private func didTapOpenInSafari() {
        guard let url = viewModel.article.url else { return }
        
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true)
    }
}

