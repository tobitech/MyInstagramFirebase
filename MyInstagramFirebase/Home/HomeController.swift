//
//  HomeController.swift
//  MyInstagramFirebase
//
//  Created by Tobi Omotayo on 16/01/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = .white
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItems()
        
        fetchAllPosts()
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
        DispatchQueue.global(qos: .background).async {
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func fetchAllPosts() {
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    fileprivate func fetchFollowingUserIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userIdsDictionaries = snapshot.value as? [String: Any] else { return }
            
            userIdsDictionaries.forEach({ (key, value) in
                Database.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostWithUser(user: user)
                })
            })
            
        }) { (err) in
            print("Failed to fetch following users ids: ", err)
        }
    }
    
    var posts = [Post]()
    
    fileprivate func fetchPosts() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostWithUser(user: user)
        }
        
    }
    
    fileprivate func fetchPostWithUser(user: User) {
        
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
//            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                self.posts.append(post)
            })
            
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate.compare(post2.creationDate) == .orderedDescending
            })
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        }) { (err) in
            print("Failed to fetch posts: ", err)
        }
    }
    
    fileprivate func setupNavigationItems() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        
    }
    
    @objc func handleCamera() {
        print("Showing camera...")
        
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        cell.delegate = self
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8
        height += view.frame.width
        height += 50
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        let post = posts[indexPath.item]
        
        guard let postId = post.id else { return }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = [uid:1]
        
        let ref = Database.database().reference().child("likes").child(postId)
        ref.updateChildValues(values) { (err, _) in
            if let err = err {
                print("Failed to like post: ", err)
                return
            }
            
            print("Successfully liked post.")
        }
    }
    
}









