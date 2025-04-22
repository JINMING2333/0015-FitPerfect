import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user ID
  String? get userId => _auth.currentUser?.uid;
  
  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
  
  // Get current username
  String? get username => _auth.currentUser?.displayName;

  // Get community posts
  Stream<QuerySnapshot> getCommunityPosts() {
    return _firestore
        .collection('community_posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // Get specific category posts
  Stream<QuerySnapshot> getCategoryPosts(String category) {
    return _firestore
        .collection('community_posts')
        .where('category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Create a new post
  Future<bool> createPost({
    required String content,
    String? title,
    String? imageUrl,
    String category = 'general',
  }) async {
    if (!isLoggedIn) return false;
    
    try {
      // Get user info
      DocumentSnapshot? userDoc = await _firestore.collection('users').doc(userId).get();
      String authorName = username ?? 'Anonymous';
      String? authorPhotoUrl;
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        authorName = userData?['username'] ?? authorName;
        authorPhotoUrl = userData?['photoUrl'];
      }
      
      // Create post document
      await _firestore.collection('community_posts').add({
        'authorId': userId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': 0,
        'likedBy': [],
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Create post error: $e');
      return false;
    }
  }
  
  // Like a post
  Future<bool> likePost(String postId) async {
    if (!isLoggedIn) return false;
    
    try {
      DocumentReference postRef = _firestore.collection('community_posts').doc(postId);
      DocumentSnapshot postDoc = await postRef.get();
      
      if (!postDoc.exists) return false;
      
      List<dynamic> likedBy = (postDoc.data() as Map<String, dynamic>)['likedBy'] ?? [];
      bool alreadyLiked = likedBy.contains(userId);
      
      if (alreadyLiked) {
        // Unlike the post
        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Like the post
        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Like post error: $e');
      return false;
    }
  }
  
  // Add comment to post
  Future<bool> addComment({
    required String postId,
    required String content,
  }) async {
    if (!isLoggedIn) return false;
    
    try {
      // Get user info
      DocumentSnapshot? userDoc = await _firestore.collection('users').doc(userId).get();
      String authorName = username ?? 'Anonymous';
      String? authorPhotoUrl;
      
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        authorName = userData?['username'] ?? authorName;
        authorPhotoUrl = userData?['photoUrl'];
      }
      
      // Create comment document
      await _firestore
          .collection('community_posts')
          .doc(postId)
          .collection('comments')
          .add({
        'authorId': userId,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Update comment count
      await _firestore
          .collection('community_posts')
          .doc(postId)
          .update({
        'comments': FieldValue.increment(1),
      });
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Add comment error: $e');
      return false;
    }
  }
  
  // Get comments for a post
  Stream<QuerySnapshot> getPostComments(String postId) {
    return _firestore
        .collection('community_posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
  
  // Delete post
  Future<bool> deletePost(String postId) async {
    if (!isLoggedIn) return false;
    
    try {
      DocumentSnapshot postDoc = await _firestore.collection('community_posts').doc(postId).get();
      
      if (!postDoc.exists) return false;
      
      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
      
      // Check if current user is the author
      if (postData['authorId'] != userId) {
        return false;
      }
      
      // Delete post
      await _firestore.collection('community_posts').doc(postId).delete();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete post error: $e');
      return false;
    }
  }
  
  // Edit post
  Future<bool> editPost({
    required String postId,
    String? title,
    String? content,
    String? imageUrl,
  }) async {
    if (!isLoggedIn) return false;
    
    try {
      DocumentSnapshot postDoc = await _firestore.collection('community_posts').doc(postId).get();
      
      if (!postDoc.exists) return false;
      
      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
      
      // Check if current user is the author
      if (postData['authorId'] != userId) {
        return false;
      }
      
      // Prepare update data
      Map<String, dynamic> updateData = {};
      
      if (title != null) {
        updateData['title'] = title;
      }
      
      if (content != null) {
        updateData['content'] = content;
      }
      
      if (imageUrl != null) {
        updateData['imageUrl'] = imageUrl;
      }
      
      // Add edited flag and timestamp
      updateData['edited'] = true;
      updateData['editTimestamp'] = FieldValue.serverTimestamp();
      
      // Update post
      await _firestore.collection('community_posts').doc(postId).update(updateData);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Edit post error: $e');
      return false;
    }
  }
  
  // Get top liked posts
  Stream<List<Map<String, dynamic>>> getTopLikedPosts(int limit) {
    return _firestore
        .collection('community_posts')
        .orderBy('likes', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            // Add the document ID to the returned data
            return {
              'id': doc.id,
              ...data,
            };
          }).toList();
        });
  }
} 