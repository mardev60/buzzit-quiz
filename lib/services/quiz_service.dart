import 'package:buzzit/models/quiz_question.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<List<QuizQuestion>> fetchQuizQuestions(String category) async {
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  final String prompt = 'Genere moi un quiz en français de 10 questions sur la catégorie : "$category" en suivant strictement ce schéma JSON. Envoie moi le json directement sans faire d`autres phrases. Voici le schema a suivre strictement : [{  "question": "Question 1",  "answers": [    "Reponse 1A",    "Reponse 1B",    "Reponse 1C"  ],  "correctAnswerIndex": 1},{  "question": "Question 2",  "answers": [    "Reponse 2A",    "Reponse 2B",    "Reponse 2C"  ],  "correctAnswerIndex": 2}].';

  final Map<String, dynamic> body = {
    "model": "llama3-8b-8192",
    "messages": [
      {
        "role": "user",
        "content": prompt
      }
    ]
  };

  final response = await http.post(
    Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: json.encode(body),
  );

if (response.statusCode == 200) {
  final String content = utf8.decode(response.bodyBytes);
  final Map<String, dynamic> jsonResponse = json.decode(content);
  final String quizContent = jsonResponse['choices'][0]['message']['content'];

  try {
    final List<dynamic> data = json.decode(quizContent.trim());
    final List<QuizQuestion> questions = data.map((item) {
      return QuizQuestion.fromJson(item);
    }).toList();
    return questions;
  } catch (e) {
    throw Exception('Failed to parse quiz questions: $e');
  }
} else {
    throw Exception('Failed to load quiz questions: ${response.body}');
  }
}