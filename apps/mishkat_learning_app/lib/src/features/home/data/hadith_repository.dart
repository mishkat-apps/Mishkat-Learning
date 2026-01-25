import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/hadith.dart';

class HadithRepository {
  final FirebaseFirestore _firestore;

  HadithRepository(this._firestore);

  Future<Hadith?> fetchDailyHadith() async {
    try {
      // 1. Get total count of hadiths
      final snapshot = await _firestore.collection('hadith').count().get();
      final count = snapshot.count ?? 0;

      if (count == 0) return null;

      // 2. Calculate daily index
      // Using sequence number 1 to N
      final daysSinceEpoch = DateTime.now().difference(DateTime(1970)).inDays;
      final dailySequence = (daysSinceEpoch % count) + 1;

      // 3. Fetch the hadith with that sequence number
      final querySnapshot = await _firestore
          .collection('hadith')
          .where('sequenceNumber', isEqualTo: dailySequence)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Hadith.fromMap(querySnapshot.docs.first.data(), querySnapshot.docs.first.id);
      }
      
      // Fallback: fetch the very first one if calculation fails to match
      final firstDoc = await _firestore.collection('hadith').orderBy('sequenceNumber').limit(1).get();
       if (firstDoc.docs.isNotEmpty) {
        return Hadith.fromMap(firstDoc.docs.first.data(), firstDoc.docs.first.id);
      }

      return null;
    } catch (e) {
      // Return null or rethrow based on app needs. 
      // For UI safety, we might just return null.
      return null; 
    }
  }

  Future<void> seedHadithDatabase() async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('hadith');

    // Clear existing to avoid duplicates if re-seeding (optional, but good for debug)
    // Note: for large collections this is bad, but for seed it's okay.
    // For now we will just overwrite based on sequence number query if we wanted to be fancy, 
    // but simplified: we'll just add them. Creating unique IDs based on sequence is cleaner.
    
    final hadiths = [
      Hadith(
        id: 'seed_1',
        narrator: 'Prophet Muhammad (SAWW)',
        arabicText: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
        englishText: 'Seeking knowledge is obligatory for every Muslim.',
        reference: 'Al-Kafi, Vol. 1, Book of Intellect and Knowledge',
        sequenceNumber: 1,
      ),
      Hadith(
        id: 'seed_2',
        narrator: 'Prophet Muhammad (SAWW)',
        arabicText: 'اُطْلُبُوا الْعِلْمَ مِنَ الْمَهْدِ إِلَى اللَّحْدِ',
        englishText: 'Seek knowledge from the cradle to the grave.',
        reference: 'Popular narration attributed to the Prophet',
        sequenceNumber: 2,
      ),
      Hadith(
        id: 'seed_3',
        narrator: 'Imam Ali (AS)',
        arabicText: 'الْعِلْمُ سُلْطَانٌ',
        englishText: 'Knowledge is power (authority).',
        reference: 'Nahj al-Balagha, Saying 147',
        sequenceNumber: 3,
      ),
      Hadith(
        id: 'seed_4',
        narrator: 'Imam Sadiq (AS)',
        arabicText: 'لَوْ يَعْلَمُ النَّاسُ مَا فِي طَلَبِ الْعِلْمِ لَطَلَبُوهُ وَ لَوْ بِسَفْكِ الْمُهَجِ وَ خَوْضِ اللُّجَجِ',
        englishText: 'If people knew the benefits of seeking knowledge, they would seek it even if it required shedding blood and diving into the depths of the sea.',
        reference: 'Bihar al-Anwar, Vol. 1, p. 177',
        sequenceNumber: 4,
      ),
      Hadith(
        id: 'seed_5',
        narrator: 'Imam Musa al-Kazim (AS)',
        arabicText: 'مَنْ لَمْ يَكُنْ لَهُ مِنْ نَفْسِهِ وَاعِظٌ تَمَكَّنَ مِنْهُ عَدُوُّهُ', // Using a knowledge/wisdom related one
        englishText: 'Conversation with a scholar on a dung heap is better than conversation with an ignorant man on carpets.', // Switching to the specific knowledge one requested
        reference: 'Tuhaf al-Uqul',
        sequenceNumber: 5,
      ),
    ];
    
    // Correction for #5 to match "knowledge" theme stronger if needed, but the above is good.
    // Actually let's use the famous one from Imam Kazim (AS) about reason/knowledge.
    // Replacement for #5:
    // "O Hisham! Allah has not established a proof against mankind clearer than Reason."
    
    // Let's stick with the provided ones or generic known ones. 
    // I will use:
    // Imam Ali (AS): "There is no wealth like wisdom, no poverty like ignorance."
    
    final finalHadiths = [
       Hadith(
        id: 'seed_1',
        narrator: 'Prophet Muhammad (SAWW)',
        arabicText: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
        englishText: 'Seeking knowledge is an obligation upon every Muslim.',
        reference: 'Al-Kafi, Vol. 1, H. 1',
        sequenceNumber: 1,
      ),
      Hadith(
        id: 'seed_2',
        narrator: 'Prophet Muhammad (SAWW)',
        arabicText: 'مَنْ سَلَكَ طَرِيقاً يَطْلُبُ فِيهِ عِلْماً سَلَكَ اللَّهُ بِهِ طَرِيقاً إِلَى الْجَنَّةِ',
        englishText: 'He who follows a path in pursuit of knowledge, Allah will make easy for him a path to Paradise.',
        reference: 'Al-Kafi, Vol. 1, p. 42',
        sequenceNumber: 2,
      ),
      Hadith(
        id: 'seed_3',
        narrator: 'Imam Ali (AS)',
        arabicText: 'لاَ كَنْزَ أَنْفَعُ مِنَ الْعِلْمِ',
        englishText: 'There is no treasure more useful than knowledge.',
        reference: 'Nahj al-Balagha, Saying 113',
        sequenceNumber: 3,
      ),
      Hadith(
        id: 'seed_4',
        narrator: 'Imam Sadiq (AS)',
        arabicText: 'زَكَاةُ الْعِلْمِ نَشْرُهُ',
        englishText: 'The Zakat (tax) of knowledge is to teach it.',
        reference: 'Al-Kafi, Vol. 1, p. 41',
        sequenceNumber: 4,
      ),
      Hadith(
        id: 'seed_5',
        narrator: 'Imam Baqir (AS)',
        arabicText: 'عَالِمٌ يُنْتَفَعُ بِعِلْمِهِ أَفْضَلُ مِنْ سَبْعِينَ أَلْفَ عَابِدٍ',
        englishText: 'A scholar who imparts his knowledge is better than seventy thousand worshippers.',
        reference: 'Al-Kafi, Vol. 1, p. 33',
        sequenceNumber: 5,
      ),
    ];

    for (var hadith in finalHadiths) {
      // Use set with merge to update if exists
      batch.set(collection.doc(hadith.id), hadith.toMap(), SetOptions(merge: true));
    }

    await batch.commit();
  }
}

final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  return HadithRepository(FirebaseFirestore.instance);
});

final dailyHadithProvider = FutureProvider<Hadith?>((ref) async {
  return ref.read(hadithRepositoryProvider).fetchDailyHadith();
});
