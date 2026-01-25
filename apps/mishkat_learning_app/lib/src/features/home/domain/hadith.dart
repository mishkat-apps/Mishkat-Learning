class Hadith {
  final String id;
  final String narrator;
  final String arabicText;
  final String englishText;
  final String reference;
  final int sequenceNumber;

  Hadith({
    required this.id,
    required this.narrator,
    required this.arabicText,
    required this.englishText,
    required this.reference,
    required this.sequenceNumber,
  });

  factory Hadith.fromMap(Map<String, dynamic> map, String id) {
    return Hadith(
      id: id,
      narrator: map['narrator'] ?? '',
      arabicText: map['arabicText'] ?? '',
      englishText: map['englishText'] ?? '',
      reference: map['reference'] ?? '',
      sequenceNumber: map['sequenceNumber']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'narrator': narrator,
      'arabicText': arabicText,
      'englishText': englishText,
      'reference': reference,
      'sequenceNumber': sequenceNumber,
    };
  }
}
