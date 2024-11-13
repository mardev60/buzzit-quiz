import 'package:buzzit/models/quiz_question.dart';
import 'package:buzzit/services/quiz_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QuizPage extends StatefulWidget {
  final String category;

  QuizPage({required this.category});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<QuizQuestion>> _quizQuestions;
  int _currentQuestionIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _quizQuestions = fetchQuizQuestions(widget.category);
  }

  void _answerQuestion(int selectedIndex, int correctIndex) {
    if (selectedIndex == correctIndex) {
      setState(() {
        _score++;
      });
    }
    if (_currentQuestionIndex < 9) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showScoreDialog();
    }
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quiz Terminé'),
        content: Text('Votre score est de $_score / 10'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz - ${widget.category}'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: _quizQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final questions = snapshot.data!;
            final currentQuestion = questions[_currentQuestionIndex];

            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / 10,
                    backgroundColor: Colors.grey[300],
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Question ${_currentQuestionIndex + 1} / 10',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shadowColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        currentQuestion.question,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ...currentQuestion.answers.asMap().entries.map((entry) {
                    int index = entry.key;
                    String answer = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () => _answerQuestion(index, currentQuestion.correctAnswerIndex),
                        child: Text(
                          answer,
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15), 
                          backgroundColor: const Color.fromARGB(255, 217, 239, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          } else {
            return Center(child: Text('Aucune question trouvée.'));
          }
        },
      ),
    );
  }
}