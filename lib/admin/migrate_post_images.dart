import 'package:cloud_firestore/cloud_firestore.dart';

String fixImageUrl(String url, String userId) {
  final broken = '$userId/$userId/';
  final fixed = '$userId/';

  if (url.contains(broken)) {
    return url.replaceFirst(broken, fixed);
  }
  return url;
}

Future<void> migratePostImageUrls() async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('posts').get();

  int fixedCount = 0;

  for (final doc in snapshot.docs) {
    final data = doc.data();

    final String? imageUrl = data['imageUrl'];
    final String? userId = data['userId'];

    if (imageUrl == null || userId == null) continue;

    final fixedUrl = fixImageUrl(imageUrl, userId);

    if (fixedUrl != imageUrl) {
      await doc.reference.update({'imageUrl': fixedUrl});
      fixedCount++;
      print('Fixed post ${doc.id}');
    }
  }

  print('✅ Migration complete. Fixed $fixedCount posts.');
}
