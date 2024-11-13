class QuizQuestion {
  final String question;
  final List<String> answers;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.answers,
    required this.correctAnswerIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      answers: List<String>.from(json['answers']),
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }
}
