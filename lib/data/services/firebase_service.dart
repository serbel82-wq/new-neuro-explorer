import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../firebase_options.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class User {
  final String id;
  final String email;
  final String? childName;
  final int? childAge;
  final DateTime createdAt;
  final bool isPremium;
  final DateTime? premiumExpiresAt;

  User({
    required this.id,
    required this.email,
    this.childName,
    this.childAge,
    required this.createdAt,
    this.isPremium = false,
    this.premiumExpiresAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'childName': childName,
        'childAge': childAge,
        'createdAt': createdAt.toIso8601String(),
        'isPremium': isPremium,
        'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        childName: json['childName'],
        childAge: json['childAge'],
        createdAt: DateTime.parse(json['createdAt']),
        isPremium: json['isPremium'] ?? false,
        premiumExpiresAt: json['premiumExpiresAt'] != null
            ? DateTime.parse(json['premiumExpiresAt'])
            : null,
      );
}

abstract class AuthBase {
  Stream<AuthStatus> get authStatus;
  User? get currentUser;
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(String email, String password,
      {String? childName, int? childAge});
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
}

class AuthService implements AuthBase {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _authStatusController = StreamController<AuthStatus>.broadcast();

  User? _currentUser;
  bool _isFirebaseConfigured = false;
  bool _isLoading = false;
  firebase_auth.FirebaseAuth? _firebaseAuth;
  CollectionReference? _usersCollection;

  @override
  Stream<AuthStatus> get authStatus => _authStatusController.stream;

  @override
  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    try {
      // Проверяем, инициализирован ли Firebase
      final apps = Firebase.apps;
      if (apps.isNotEmpty) {
        _firebaseAuth = firebase_auth.FirebaseAuth.instance;
        _isFirebaseConfigured = true;

        // Получаем ссылку на коллекцию пользователей
        _usersCollection = FirebaseFirestore.instance.collection('users');

        // Слушаем изменения auth state
        _firebaseAuth!.authStateChanges().listen((user) {
          if (user != null) {
            _authStatusController.add(AuthStatus.authenticated);
          } else {
            _authStatusController.add(AuthStatus.unauthenticated);
          }
        });

        debugPrint('AuthService: Firebase настроен и готов к работе');
      } else {
        _isFirebaseConfigured = false;
        debugPrint(
            'AuthService: Firebase не инициализирован, используем локальный режим');
      }
      _authStatusController.add(AuthStatus.unauthenticated);
    } catch (e) {
      debugPrint('AuthService init error: $e');
      _isFirebaseConfigured = false;
      _authStatusController.add(AuthStatus.unauthenticated);
    }
  }

  Future<User?> _createUserDocument(firebase_auth.User firebaseUser,
      {String? childName, int? childAge}) async {
    if (_usersCollection == null) return null;

    try {
      final docRef = _usersCollection!.doc(firebaseUser.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // Создаем нового пользователя в Firestore
        await docRef.set({
          'email': firebaseUser.email,
          'childName': childName,
          'childAge': childAge,
          'createdAt': FieldValue.serverTimestamp(),
          'isPremium': false,
          'completedLessons': <int>[],
          'currentSeason': 1,
          'currentLesson': 1,
          'xp': 0,
          'level': 1,
          'achievements': <String>[],
        });
      }

      // Получаем данные пользователя
      final data = doc.data() as Map<String, dynamic>?;
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        childName: data?['childName'] as String? ?? childName,
        childAge: data?['childAge'] as int? ?? childAge,
        createdAt: DateTime.now(),
        isPremium: data?['isPremium'] as bool? ?? false,
        premiumExpiresAt: data?['premiumExpiresAt'] != null
            ? DateTime.parse(data!['premiumExpiresAt'] as String)
            : null,
      );
    } catch (e) {
      debugPrint('Error creating user document: $e');
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        childName: childName,
        childAge: childAge,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<User?> signIn(String email, String password) async {
    if (_isLoading) return null;
    _isLoading = true;
    _authStatusController.add(AuthStatus.loading);

    try {
      if (_isFirebaseConfigured && _firebaseAuth != null) {
        // Реальная авторизация через Firebase
        final result = await _firebaseAuth!.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (result.user != null) {
          _currentUser = await _createUserDocument(result.user!);
          _authStatusController.add(AuthStatus.authenticated);
          return _currentUser;
        }
      } else {
        // Локальная заглушка для MVP
        await Future.delayed(const Duration(seconds: 1));

        if (email.isNotEmpty && password.length >= 6) {
          _currentUser = User(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            createdAt: DateTime.now(),
          );
          _authStatusController.add(AuthStatus.authenticated);
          return _currentUser;
        }
        throw Exception('Неверный email или пароль');
      }
    } catch (e) {
      _authStatusController.add(AuthStatus.error);
      rethrow;
    } finally {
      _isLoading = false;
    }
    return null;
  }

  @override
  Future<User?> signUp(String email, String password,
      {String? childName, int? childAge}) async {
    if (_isLoading) return null;
    _isLoading = true;
    _authStatusController.add(AuthStatus.loading);

    try {
      if (_isFirebaseConfigured && _firebaseAuth != null) {
        // Реальная регистрация через Firebase
        final result = await _firebaseAuth!.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (result.user != null) {
          // Создаем документ пользователя в Firestore
          _currentUser = await _createUserDocument(
            result.user!,
            childName: childName,
            childAge: childAge,
          );
          _authStatusController.add(AuthStatus.authenticated);
          return _currentUser;
        }
      } else {
        // Локальная заглушка для MVP
        await Future.delayed(const Duration(seconds: 1));

        if (email.isNotEmpty && password.length >= 6) {
          _currentUser = User(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            childName: childName,
            childAge: childAge,
            createdAt: DateTime.now(),
          );
          _authStatusController.add(AuthStatus.authenticated);
          return _currentUser;
        }
        throw Exception('Пароль должен быть не менее 6 символов');
      }
    } catch (e) {
      _authStatusController.add(AuthStatus.error);
      rethrow;
    } finally {
      _isLoading = false;
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    if (_isFirebaseConfigured && _firebaseAuth != null) {
      await _firebaseAuth!.signOut();
    }
    _currentUser = null;
    _authStatusController.add(AuthStatus.unauthenticated);
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (_isFirebaseConfigured && _firebaseAuth != null) {
      await _firebaseAuth!.sendPasswordResetEmail(email: email);
    } else {
      // Заглушка
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Password reset email would be sent to: $email');
    }
  }

  void dispose() {
    _authStatusController.close();
  }
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  CollectionReference? _usersCollection;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final apps = Firebase.apps;
      if (apps.isNotEmpty) {
        _usersCollection = FirebaseFirestore.instance.collection('users');
        _isInitialized = true;
        debugPrint('FirebaseService: Firestore инициализирован');
      }
    } catch (e) {
      debugPrint('FirebaseService initialization error: $e');
    }
  }

  Future<void> saveUserProgress(
      String userId, Map<String, dynamic> progress) async {
    if (_usersCollection == null) {
      debugPrint('Mock: Saving progress for user $userId: $progress');
      return;
    }

    try {
      await _usersCollection!
          .doc(userId)
          .set(progress, SetOptions(merge: true));
      debugPrint('Progress saved to Firestore for user $userId');
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProgress(String userId) async {
    if (_usersCollection == null) {
      debugPrint('Mock: Getting progress for user $userId');
      return null;
    }

    try {
      final doc = await _usersCollection!.doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error getting progress: $e');
      return null;
    }
  }

  Future<void> saveChildProgress(
      String parentId, String childId, Map<String, dynamic> progress) async {
    if (_usersCollection == null) {
      debugPrint(
          'Mock: Saving child progress for $childId from parent $parentId');
      return;
    }

    try {
      await _usersCollection!
          .doc(childId)
          .set(progress, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving child progress: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getChildren(String parentId) async {
    if (_usersCollection == null) {
      debugPrint('Mock: Getting children for parent $parentId');
      return [];
    }

    try {
      final snapshot =
          await _usersCollection!.where('parentId', isEqualTo: parentId).get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error getting children: $e');
      return [];
    }
  }
}

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  static const String _trialUsedKey = 'trial_used';
  static const int trialDays = 7;
  static const int monthlyPriceRubles = 990;
  static const int yearlyPriceRubles = 7990;

  bool _isTrialActive = false;
  bool _isSubscribed = false;
  bool _hasAIAssistant = false;
  DateTime? _subscriptionEnd;

  bool get isSubscribed => _isSubscribed;
  bool get isTrialActive => _isTrialActive;
  bool get hasAIAssistant => _hasAIAssistant;
  DateTime? get subscriptionEnd => _subscriptionEnd;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isTrialActive = !(prefs.getBool(_trialUsedKey) ?? false);
  }

  Future<bool> activateTrial() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyUsed = prefs.getBool(_trialUsedKey) ?? false;
    
    if (alreadyUsed) {
      return false;
    }
    
    await prefs.setBool(_trialUsedKey, true);
    _isTrialActive = true;
    _subscriptionEnd = DateTime.now().add(Duration(days: trialDays));
    return true;
  }

  Future<bool> subscribe(
      {required int months, required String paymentMethodId, bool withAI = false}) async {
    await Future.delayed(const Duration(seconds: 2));

    _isTrialActive = false;
    _isSubscribed = true;
    _hasAIAssistant = withAI;
    _subscriptionEnd = DateTime.now().add(Duration(days: 30 * months));

    return true;
  }

  Future<bool> cancelSubscription() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isSubscribed = false;
    return true;
  }

  Future<void> checkSubscriptionStatus() async {
    if (_subscriptionEnd != null && DateTime.now().isAfter(_subscriptionEnd!)) {
      _isSubscribed = false;
      _isTrialActive = false;
    }
  }

  Map<String, dynamic> getSubscriptionInfo() {
    return {
      'isSubscribed': _isSubscribed,
      'isTrialActive': _isTrialActive,
      'subscriptionEnd': _subscriptionEnd?.toIso8601String(),
      'trialDaysRemaining': _subscriptionEnd != null
          ? _subscriptionEnd!.difference(DateTime.now()).inDays
          : trialDays,
      'monthlyPrice': monthlyPriceRubles,
      'yearlyPrice': yearlyPriceRubles,
      'hasAIAssistant': _isSubscribed && _hasAIAssistant,
    };
  }
}
