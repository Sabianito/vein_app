import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/models.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static Future<bool> connectivityCheck() async {
    try {
      await FirebaseFirestore.instance.collection('_check_').doc('_test_').get();
      return true;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => _auth.currentUser != null;

  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await cred.user?.updateDisplayName(displayName.trim());
    }
    return cred;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  String? get userId => _auth.currentUser?.uid;
  String? get userEmail => _auth.currentUser?.email;
  String? get displayName => _auth.currentUser?.displayName;

  String get userIdOrFallback => userId ?? 'guest';

  Future<void> saveUserProfile(UserProfile profile) async {
    await _firestore
        .collection('users')
        .doc(userIdOrFallback)
        .set(profile.toJson());
  }

  Future<UserProfile?> loadUserProfile() async {
    final doc = await _firestore
        .collection('users')
        .doc(userIdOrFallback)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromJson(doc.data()!);
  }

  Future<void> saveWorkoutHistory(List<WorkoutLogEntry> history) async {
    await _firestore
        .collection('users')
        .doc(userIdOrFallback)
        .collection('history')
        .get()
        .then((snap) async {
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    });
    final batch = _firestore.batch();
    for (final entry in history) {
      final ref = _firestore
          .collection('users')
          .doc(userIdOrFallback)
          .collection('history')
          .doc(entry.id);
      batch.set(ref, entry.toJson());
    }
    await batch.commit();
  }

  Future<List<WorkoutLogEntry>> loadWorkoutHistory() async {
    final snap = await _firestore
        .collection('users')
        .doc(userIdOrFallback)
        .collection('history')
        .orderBy('completedAt', descending: true)
        .get();
    return snap.docs
        .map((doc) => WorkoutLogEntry.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveExerciseStats(Map<String, ExerciseStats> stats) async {
    final data = stats.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await _firestore
        .collection('users')
        .doc(userIdOrFallback)
        .update({'exerciseStats': data});
  }

  Future<Map<String, ExerciseStats>> loadExerciseStats() async {
    final doc = await _firestore
        .collection('users')
        .doc(userIdOrFallback)
        .get();
    final raw = doc.data()?['exerciseStats'] as Map<String, dynamic>?;
    if (raw == null) return {};
    return raw.map(
      (key, value) => MapEntry(
        key,
        ExerciseStats.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> saveUserPreferences(UserPreferences prefs) async {
    await _firestore
        .collection('users')
        .doc(userIdOrFallback)
        .update({'preferences': prefs.toJson()});
  }

  Future<UserPreferences?> loadUserPreferences() async {
    final doc = await _firestore
        .collection('users')
        .doc(userIdOrFallback)
        .get();
    final raw = doc.data()?['preferences'] as Map<String, dynamic>?;
    if (raw == null) return null;
    return UserPreferences.fromJson(raw);
  }
}
