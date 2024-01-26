import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardRepository {
  Future<void> addAction() async {
    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection("dashboard")
          .where("userId", isEqualTo: userId)
          .where("date", isEqualTo: today.millisecondsSinceEpoch)
          .get();
      if (snapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection("dashboard").add({
          "userId": userId,
          "date": today.millisecondsSinceEpoch,
          "actions": 1,
        });
      } else {
        await FirebaseFirestore.instance.collection("dashboard").doc(snapshot.docs.first.id).update({
          "actions": FieldValue.increment(1),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<DateTime, int>> getDashboard() async {
    Map<DateTime, int> dashboard = {};
    try {
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      final snapshots = await FirebaseFirestore.instance.collection("dashboard").where("userId", isEqualTo: userId).get();
      if (snapshots.docs.isNotEmpty) {
        for (var doc in snapshots.docs) {
          dashboard.addAll(
            {
              DateTime.fromMillisecondsSinceEpoch(doc.data()["date"] ?? DateTime(2000, 1, 1).millisecondsSinceEpoch):
                  doc.data()["actions"] ?? 0
            },
          );
        }
      }
      return dashboard;
    } catch (e) {
      rethrow;
    }
  }
}
