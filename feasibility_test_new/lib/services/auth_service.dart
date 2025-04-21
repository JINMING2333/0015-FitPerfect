import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthService() {
    // 监听用户登录状态变化
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // 获取当前用户
  User? get user => _user;
  
  // 是否有用户已登录
  bool get isLoggedIn => _user != null;
  
  // 是否加载中
  bool get isLoading => _isLoading;
  
  // 错误消息
  String? get errorMessage => _errorMessage;

  // 注册
  Future<bool> register(String email, String password, String username) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 注册账户
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 创建用户信息
      if (userCredential.user != null) {
        // 更新用户显示名
        await userCredential.user!.updateDisplayName(username);
        
        // 在Firestore中存储用户信息
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // 更新本地存储
        await _updateLocalLoginStatus(true, username);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      
      switch (e.code) {
        case 'weak-password':
          _errorMessage = '密码强度太弱';
          break;
        case 'email-already-in-use':
          _errorMessage = '该邮箱已被注册';
          break;
        case 'invalid-email':
          _errorMessage = '邮箱格式不正确';
          break;
        default:
          _errorMessage = '注册失败: ${e.message}';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '发生错误: $e';
      notifyListeners();
      return false;
    }
  }

  // 登录
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 登录
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // 更新Firestore中的最后登录时间
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // 更新本地存储
        String username = userCredential.user!.displayName ?? email.split('@')[0];
        await _updateLocalLoginStatus(true, username);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = '用户不存在';
          break;
        case 'wrong-password':
          _errorMessage = '密码错误';
          break;
        case 'invalid-credential':
          _errorMessage = '用户名或密码错误';
          break;
        case 'user-disabled':
          _errorMessage = '该账户已被禁用';
          break;
        default:
          _errorMessage = '登录失败: ${e.message}';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '发生错误: $e';
      notifyListeners();
      return false;
    }
  }

  // 退出登录
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _updateLocalLoginStatus(false, null);
    } catch (e) {
      _errorMessage = '退出登录失败: $e';
      notifyListeners();
    }
  }

  // 更新本地登录状态
  Future<void> _updateLocalLoginStatus(bool isLoggedIn, String? username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('login_status', isLoggedIn);
      
      if (username != null) {
        await prefs.setString('username', username);
      } else {
        await prefs.remove('username');
      }
    } catch (e) {
      debugPrint('更新本地登录状态错误: $e');
    }
  }

  // 密码重置
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = '该邮箱未注册';
          break;
        case 'invalid-email':
          _errorMessage = '邮箱格式不正确';
          break;
        default:
          _errorMessage = '重置密码失败: ${e.message}';
      }
      
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '发生错误: $e';
      notifyListeners();
      return false;
    }
  }
} 