/// Ein fachlich zusammengehöriges Paar. Texte bleiben als barrierearme Bildbeschriftung erhalten.
class ZuordnungPair {
  final String label;
  final String answer;
  final int? id;
  final String? labelImageUrl;
  final String? answerImageUrl;
  final String? answerAudioUrl;

  const ZuordnungPair(
    this.label,
    this.answer, {
    this.id,
    this.labelImageUrl,
    this.answerImageUrl,
    this.answerAudioUrl,
  });
}
