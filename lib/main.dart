import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:archive/archive.dart';

void main() => runApp(const MyApp());

ThemeData _darkTheme = ThemeData(
  scaffoldBackgroundColor: const Color.fromARGB(0xff, 0x28, 0x28, 0x28),
  cardColor: const Color.fromARGB(0xff, 0x28, 0x28, 0x38),
  primaryColor: const Color.fromARGB(0xff, 0x28, 0x28, 0xbb),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: Color.fromARGB(0xff, 0xd4, 0xd4, 0xd4),
    ),
    bodySmall: TextStyle(
      color: Color.fromARGB(0xff, 0xd4, 0xd4, 0xd4),
    ),
  ),
);

ThemeData _lightTheme = ThemeData(
  scaffoldBackgroundColor: const Color.fromARGB(0xff, 0xf5, 0xf5, 0xf5),
  cardColor: const Color.fromARGB(0xff, 0xc5, 0xc5, 0xf5),
  primaryColor: const Color.fromARGB(0xff, 0x28, 0x28, 0xbb),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color.fromARGB(0xff, 0x08, 0x08, 0x08)),
    bodySmall: TextStyle(
      color: Color.fromARGB(0xff, 0xd4, 0xd4, 0xd4),
    ),
  ),
);

class Question extends StatefulWidget {
  final QuestionSet questionSet;
  final int questionKey;

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
      widget.questionSet.questions[widget.questionKey];
  int get maxQuestion => widget.questionSet.questions.length;
  ScrollController scrollController = ScrollController();

  List<bool> isAnswerShown = [false, false];

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
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(constraints.maxHeight * 0.02),
                  child: ElevatedButton(
                    onPressed: () => MyApp.of(context).toggleTheme(),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      "Change the colour",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width > 800
                      ? 640
                      : constraints.maxWidth * 0.8,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.85,
                    ),
                    child: Card(
                      color: Theme.of(context).cardColor,
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(
                              Theme.of(context).primaryColor),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildImage(constraints),
                                  _buildQuestionText(constraints),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.03),
                                  _buildAnswerButton(
                                      constraints, currentQuestion.answer1, 0),
                                  SizedBox(
                                      height: constraints.maxHeight * 0.03),
                                  _buildAnswerButton(
                                      constraints, currentQuestion.answer2, 1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(BoxConstraints constraints) {
    return Padding(
      padding: EdgeInsets.only(top: constraints.maxHeight * 0.03, bottom: constraints.maxHeight * 0.03),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: CachedNetworkImage(
            imageUrl: "https://raw.githubusercontent.com/Bartek0x00/Modern-Cities/main/assets/images/${currentQuestion.image}",
            placeholder: (context, url) => Center(
                child: SizedBox(
              width: constraints.maxHeight * 0.1,
              height: constraints.maxHeight * 0.1,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: constraints.maxHeight * 0.01,
              ),
            )),
            width: (constraints.maxWidth > 800) ? 600 : constraints.maxWidth * 0.65,
            height: constraints.maxHeight * 0.45,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 250),
            fadeOutDuration: const Duration(milliseconds: 50),
            errorWidget: (context, url, error) => Center(
                child: SizedBox(
              width: constraints.maxHeight * 0.1,
              height: constraints.maxHeight * 0.1,
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
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
          isAnswerShown[0] = true;
        });
      }
    });
    return AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            currentQuestion.question,
            textStyle: TextStyle(
              fontSize: constraints.maxHeight * 0.03,
            ),
            textAlign: TextAlign.center,
            speed: const Duration(milliseconds: 45),
          ),
        ],
        isRepeatingAnimation: false,
        displayFullTextOnTap: true,
        onTap: () {
          setState(() {
            isAnswerShown[0] = true;
          });
        });
  }

  void _navigateToNextQuestion(
      BuildContext context, int nextQuestionKey, bool isUp) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          if (nextQuestionKey == -1) {
            return const HomeScreen();
          } else {
            return Question(
              questionSet: widget.questionSet,
              questionKey: (nextQuestionKey < maxQuestion)
                  ? nextQuestionKey
                  : (maxQuestion - 1),
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

  Widget _buildAnswerButton(
      BoxConstraints constraints, String answer, int num) {
    if (isAnswerShown[num] && answer.isNotEmpty) {
      Future.delayed(
          Duration(milliseconds: 45 * currentQuestion.answer1.length), () {
        if (mounted && num == 0) {
          setState(() {
            isAnswerShown[1] = true;
          });
        }
      });
      return ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all(Theme.of(context).primaryColor),
        ),
        onPressed: () {
          _navigateToNextQuestion(
              context,
              (num == 1)
                  ? currentQuestion.afterAnswer2
                  : currentQuestion.afterAnswer1,
              true);
        },
        child: IgnorePointer(
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                answer,
                textStyle: TextStyle(
                  fontSize: constraints.maxHeight * 0.02,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
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
}

class QuestionData {
  final String question;
  final String image;
  final String answer1;
  final String answer2;
  final int afterAnswer1;
  final int afterAnswer2;

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
      answer1: json['a1'] ?? '',
      answer2: json['a2'] ?? '',
      afterAnswer1: json['aa1'] ?? -1,
      afterAnswer2: json['aa2'] ?? -1,
    );
  }
}

class QuestionSet {
  final List<QuestionData> questions;
  QuestionSet({required this.questions});

  factory QuestionSet.fromJson(List<dynamic> json) {
    final questions = <QuestionData>[];
    DateTime currentTime = DateTime.now();
    //int i = 2 * (currentTime.minute % 8) + (currentTime.second ~/ 30);
    int i = 0;
    for (int j = 0; j < json[i].length; j++) {
      questions.add(QuestionData.fromJson(json[i][j]));
    }
    return QuestionSet(questions: questions);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: const HomeScreen(),
    );
  }

  void toggleTheme() {
    ThemeMode next;
    if (_themeMode == ThemeMode.light) {
      next = ThemeMode.dark;
    } else {
      next = ThemeMode.light;
    }

    setState(() {
      _themeMode = next;
    });
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<QuestionSet?> loadUserData() async {
    final byteData = await rootBundle.load('assets/data_mini.json.gz');
    List<int> compressedBytes = byteData.buffer.asUint8List();
    String jsonString = utf8.decode(GZipDecoder().decodeBytes(compressedBytes));

    return QuestionSet.fromJson(json.decode(jsonString));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Generating content...",
                    style: TextStyle(
                      fontSize: 32.0,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final questionSet = snapshot.data!;

          return Question(
            questionSet: questionSet,
            questionKey: 0,
          );
        } else {
          return Scaffold(
            body: Center(
                child: Text('Error: ${snapshot.error ?? 'Unknown error'}')),
          );
        }
      },
    );
  }
}
