import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class Question extends StatefulWidget {
  final QuestionSet questionSet;
  final String questionKey;

  const Question({
    super.key,
    required this.questionSet,
    required this.questionKey,
  });

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  QuestionData get currentQuestion =>
      widget.questionSet.questions[widget.questionKey]!;
  ScrollController scrollController = ScrollController();

  bool _isFirstAnswerShown = false;
  bool _isSecondAnswerShown = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: MediaQuery.of(context).size.width > 800
                  ? 640
                  : constraints.maxWidth * 0.8,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.85,
                ),
                child: Card(
                  color: Colors.grey[900],
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(
                          const Color.fromARGB(0xff, 0x28, 0x28, 0xbb)),
                    ),
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: (constraints.maxWidth > 800)
                                ? 50
                                : constraints.maxWidth * 0.05,
                            right: (constraints.maxWidth > 800)
                                ? 50
                                : constraints.maxWidth * 0.05,
                            bottom: constraints.maxHeight * 0.03,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildImage(constraints),
                              _buildQuestionText(constraints),
                              SizedBox(height: constraints.maxHeight * 0.03),
                              _buildAnswer1Button(constraints),
                              SizedBox(height: constraints.maxHeight * 0.03),
                              _buildAnswer2Button(constraints),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(BoxConstraints constraints) {
    return SizedBox(
      height: constraints.maxHeight * 0.4,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: CachedNetworkImage(
          imageUrl: currentQuestion.image,
          placeholder: (context, url) => Center(
              child: SizedBox(
            width: constraints.maxHeight * 0.1,
            height: constraints.maxHeight * 0.1,
            child: CircularProgressIndicator(
              color: const Color.fromARGB(0xff, 0x28, 0x28, 0xbb),
              strokeWidth: constraints.maxHeight * 0.01,
            ),
          )),
          errorWidget: (context, url, error) => Center(
              child: SizedBox(
            width: constraints.maxHeight * 0.1,
            height: constraints.maxHeight * 0.1,
            child: CircularProgressIndicator(
              color: const Color.fromARGB(0xff, 0x28, 0x28, 0xbb),
              strokeWidth: constraints.maxHeight * 0.01,
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildQuestionText(BoxConstraints constraints) {
    Future.delayed(Duration(milliseconds: 45 * currentQuestion.question.length),
        () {
      if (mounted) {
        setState(() {
          _isFirstAnswerShown = true;
        });
      }
    });
    return AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            currentQuestion.question,
            textStyle: TextStyle(
                fontSize: constraints.maxHeight * 0.03, color: Colors.white),
            textAlign: TextAlign.center,
            speed: const Duration(milliseconds: 45),
          ),
        ],
        isRepeatingAnimation: false,
        displayFullTextOnTap: true,
        onTap: () {
          setState(() {
            _isFirstAnswerShown = true;
          });
        });
  }

  void _navigateToNextQuestion(
      BuildContext context, String nextQuestionKey, bool isUp) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          if (nextQuestionKey == 'newstory') {
            return const HomeScreen();
          } else {
            return Question(
              questionSet: widget.questionSet,
              questionKey: nextQuestionKey,
              key: ValueKey(nextQuestionKey),
            );
          }
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Animatable<Offset> tween = Tween(
            begin: Offset(0.0, (isUp ? -1.0 : 1.0)),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));

          return SlideTransition(
              position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _buildAnswer1Button(BoxConstraints constraints) {
    if (_isFirstAnswerShown) {
      Future.delayed(
          Duration(milliseconds: 45 * currentQuestion.answer1.length), () {
        if (mounted) {
          setState(() {
            _isSecondAnswerShown = true;
          });
        }
      });
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(0xff, 0x28, 0x28, 0xbb),
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          _navigateToNextQuestion(context, currentQuestion.afterAnswer1, true);
        },
        child: IgnorePointer(
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                currentQuestion.answer1,
                textStyle: TextStyle(fontSize: constraints.maxHeight * 0.02),
                textAlign: TextAlign.center,
                speed: const Duration(milliseconds: 45),
              ),
            ],
            isRepeatingAnimation: false,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildAnswer2Button(BoxConstraints constraints) {
    if (_isSecondAnswerShown) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(0xff, 0x28, 0x28, 0xbb),
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          _navigateToNextQuestion(context, currentQuestion.afterAnswer2, false);
        },
        child: IgnorePointer(
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                currentQuestion.answer2,
                textStyle: TextStyle(fontSize: constraints.maxHeight * 0.02),
                textAlign: TextAlign.center,
                speed: const Duration(milliseconds: 50),
              ),
            ],
            isRepeatingAnimation: false,
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class QuestionData {
  final String question;
  final String image;
  final String answer1;
  final String answer2;
  final String afterAnswer1;
  final String afterAnswer2;

  const QuestionData(
      {required this.question,
      required this.image,
      required this.answer1,
      required this.answer2,
      required this.afterAnswer1,
      required this.afterAnswer2});

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      question: json['q'] ?? 'Question_placeholder',
      image: json['img'] ?? '',
      answer1: json['a1'] ?? 'Answer1_placeholder',
      answer2: json['a2'] ?? 'Answer2_placeholder',
      afterAnswer1: json['aa1'] ?? 'newstory',
      afterAnswer2: json['aa2'] ?? 'newstory',
    );
  }
}

class QuestionSet {
  final Map<String, QuestionData> questions;
  QuestionSet({required this.questions});

  factory QuestionSet.fromJson(Map<String, dynamic> json) {
    final List<dynamic> qsList = json['qs'];
    final questions = <String, QuestionData>{};

    for (var questionMap in qsList) {
      questionMap.forEach((key, value) {
        questions[key] = QuestionData.fromJson(value);
      });
    }
    return QuestionSet(questions: questions);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<QuestionSet?> loadUserData() async {
    try {
      final apiKey = utf8
          .decode(base64.decode(const String.fromEnvironment('GEMINI_KEY')));
      if (apiKey.isEmpty) {
        return null;
      }

      final chat = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 1.2,
          topK: 30,
          topP: 0.9,
          maxOutputTokens: 8192,
          responseMimeType: 'application/json',
        ),
      ).startChat();

      const prompt =
          'generate a json (as a choice game about decision making of high tech futuristic cities) having only qs array that has q1, q2, ... (ordinal numbers) objects each separately having inside of itself field q - a hypotethical question, img - path to img showing this, a1, a2 - possible answers, aa1, aa2 - name of questions that will appear after given ans was chosen. Try to make the question relate to each other in a plot even go back to prev questions, no comments, no unnec nesting on final question give answer1 which leads to the first question and answer2 with "newstory" aa2 field';

      final response = await chat.sendMessage(Content.text(prompt));

      if (response.text == null || response.text!.isEmpty) {
        return null;
      }

      final Map<String, dynamic> jsonString = jsonDecode(response.text!);

      return QuestionSet.fromJson(jsonString);
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: Color.fromARGB(0xff, 0x28, 0x28, 0xbb),
                  ),
                  Text("Generating a story"),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final questionSet = snapshot.data!;
          final questionKey = questionSet.questions.keys.first;

          return Question(
            questionSet: questionSet,
            questionKey: questionKey,
          );
        } else {
          return Text('Error: ${snapshot.error}');
        }
      },
    );
  }
}
