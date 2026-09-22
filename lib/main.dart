import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TaalimApp());
}

/// ---------------------------------------------------------------
/// DATA MODELS
/// ---------------------------------------------------------------
class Exercise {
  final String type; // 'qcm' or 'match'
  final String? q;
  final List<String>? options;
  final int? answer;
  final List<List<String>>? pairs; // list of [left, right]

  Exercise.qcm({required this.q, required this.options, required this.answer})
      : type = 'qcm',
        pairs = null;

  Exercise.match({required this.pairs})
      : type = 'match',
        q = null,
        options = null,
        answer = null;
}

/// ---------------------------------------------------------------
/// I18N STRINGS
/// ---------------------------------------------------------------
class Strings {
  final String homeTitle;
  final String homeSub;
  final String cp1Name;
  final String cp1Hint;
  final String cp2Name;
  final String cp2Hint;
  final String chooseSubject;
  final String lecture;
  final String calcul;
  final String best;
  final String noScore;
  final String question;
  final String matchInstruction;
  final String correct;
  final String incorrect;
  final String next;
  final String seeResult;
  final String resultTitle;
  final String Function(int, int) resultText;
  final String home;
  final String retry;

  const Strings({
    required this.homeTitle,
    required this.homeSub,
    required this.cp1Name,
    required this.cp1Hint,
    required this.cp2Name,
    required this.cp2Hint,
    required this.chooseSubject,
    required this.lecture,
    required this.calcul,
    required this.best,
    required this.noScore,
    required this.question,
    required this.matchInstruction,
    required this.correct,
    required this.incorrect,
    required this.next,
    required this.seeResult,
    required this.resultTitle,
    required this.resultText,
    required this.home,
    required this.retry,
  });
}

final Map<String, Strings> i18n = {
  'fr': Strings(
    homeTitle: "Apprendre en s'amusant",
    homeSub: "Choisis ton niveau pour commencer",
    cp1Name: "CP1",
    cp1Hint: "Première année",
    cp2Name: "CP2",
    cp2Hint: "Deuxième année",
    chooseSubject: "Choisis une matière",
    lecture: "Lecture",
    calcul: "Calcul",
    best: "Meilleur score : ",
    noScore: "Pas encore essayé",
    question: "Question",
    matchInstruction: "Touche deux cases qui vont ensemble",
    correct: "Bravo, bonne réponse !",
    incorrect: "Pas tout à fait, réessaie !",
    next: "Continuer",
    seeResult: "Voir mon résultat",
    resultTitle: "Résultat",
    resultText: (s, t) => "Tu as obtenu $s sur $t !",
    home: "Accueil",
    retry: "Recommencer",
  ),
  'ar': Strings(
    homeTitle: "تعلّم وأنت تلعب",
    homeSub: "اختر مستواك للبدء",
    cp1Name: "الأولى ابتدائي",
    cp1Hint: "السنة الأولى",
    cp2Name: "الثانية ابتدائي",
    cp2Hint: "السنة الثانية",
    chooseSubject: "اختر مادة",
    lecture: "القراءة",
    calcul: "الحساب",
    best: "أفضل نتيجة: ",
    noScore: "لم تجرب بعد",
    question: "سؤال",
    matchInstruction: "المس مربعين مرتبطين ببعضهما",
    correct: "أحسنت، إجابة صحيحة!",
    incorrect: "ليست صحيحة، حاول مجددًا!",
    next: "متابعة",
    seeResult: "شاهد نتيجتي",
    resultTitle: "النتيجة",
    resultText: (s, t) => "لقد حصلت على $s من $t!",
    home: "الرئيسية",
    retry: "إعادة المحاولة",
  ),
};

/// ---------------------------------------------------------------
/// CONTENT (exercises) — content[lang][level][subject]
/// ---------------------------------------------------------------
final Map<String, Map<String, Map<String, List<Exercise>>>> content = {
  'fr': {
    'cp1': {
      'lecture': [
        Exercise.qcm(q: "Quelle lettre vient après le A ?", options: ["B", "C", "D", "E"], answer: 0),
        Exercise.qcm(q: "Quel mot commence par la lettre M ?", options: ["Maison", "Voiture", "Soleil", "Table"], answer: 0),
        Exercise.qcm(q: "Trouve la voyelle.", options: ["O", "P", "T", "K"], answer: 0),
        Exercise.qcm(q: "Quelle lettre fait le son « ch » comme dans « chat » ?", options: ["CH", "S", "V", "J"], answer: 0),
        Exercise.match(pairs: [
          ["B", "Ballon 🎈"],
          ["C", "Chat 🐱"],
          ["L", "Lune 🌙"],
          ["S", "Soleil ☀️"],
        ]),
      ],
      'calcul': [
        Exercise.qcm(q: "2 + 3 = ?", options: ["5", "4", "6", "3"], answer: 0),
        Exercise.qcm(q: "Combien y a-t-il de pommes ? 🍎🍎🍎", options: ["3", "2", "4", "5"], answer: 0),
        Exercise.qcm(q: "5 - 2 = ?", options: ["3", "2", "4", "1"], answer: 0),
        Exercise.qcm(q: "Quel nombre vient après 7 ?", options: ["8", "6", "9", "7"], answer: 0),
        Exercise.match(pairs: [
          ["2", "⭐⭐"],
          ["4", "⭐⭐⭐⭐"],
          ["1", "⭐"],
          ["5", "⭐⭐⭐⭐⭐"],
        ]),
      ],
    },
    'cp2': {
      'lecture': [
        Exercise.qcm(q: "Quel mot correspond à l'image ? 🐱", options: ["Chat", "Chien", "Oiseau", "Poisson"], answer: 0),
        Exercise.qcm(q: "Complète : Le ___ vole dans le ciel.", options: ["oiseau", "poisson", "chat", "chien"], answer: 0),
        Exercise.qcm(q: "Quel mot est écrit correctement ?", options: ["École", "Ecolle", "Ekole", "Aicole"], answer: 0),
        Exercise.qcm(q: "Quel mot rime avec « balle » ?", options: ["salle", "porte", "lune", "fleur"], answer: 0),
        Exercise.match(pairs: [
          ["Chat", "🐱"],
          ["Chien", "🐶"],
          ["Oiseau", "🐦"],
          ["Poisson", "🐟"],
        ]),
      ],
      'calcul': [
        Exercise.qcm(q: "Sara a 5 bonbons, elle en mange 2. Combien lui en reste-t-il ?", options: ["3", "2", "7", "4"], answer: 0),
        Exercise.qcm(q: "8 - 3 = ?", options: ["5", "4", "6", "3"], answer: 0),
        Exercise.qcm(q: "4 + 4 = ?", options: ["8", "7", "9", "6"], answer: 0),
        Exercise.qcm(q: "Quel est le plus grand nombre ?", options: ["9", "6", "3", "1"], answer: 0),
        Exercise.match(pairs: [
          ["3+2", "5"],
          ["6-1", "5"],
          ["4+4", "8"],
          ["9-3", "6"],
        ]),
      ],
    },
  },
  'ar': {
    'cp1': {
      'lecture': [
        Exercise.qcm(q: "ما هو الحرف الذي يأتي بعد الألف (أ) ؟", options: ["ب", "ت", "ث", "ج"], answer: 0),
        Exercise.qcm(q: "أي كلمة تبدأ بحرف « س » ؟", options: ["سمكة", "قطة", "تفاحة", "كتاب"], answer: 0),
        Exercise.qcm(q: "أوجد حرف المد.", options: ["ا", "ب", "ت", "ث"], answer: 0),
        Exercise.qcm(q: "أي حرف يصدر صوت « م » كما في كلمة « موز » ؟", options: ["م", "ن", "ل", "ر"], answer: 0),
        Exercise.match(pairs: [
          ["ب", "بطة 🦆"],
          ["ت", "تفاحة 🍎"],
          ["س", "سمكة 🐟"],
          ["م", "موز 🍌"],
        ]),
      ],
      'calcul': [
        Exercise.qcm(q: "2 + 3 = ؟", options: ["5", "4", "6", "3"], answer: 0),
        Exercise.qcm(q: "كم عدد التفاحات ؟ 🍎🍎🍎", options: ["3", "2", "4", "5"], answer: 0),
        Exercise.qcm(q: "5 - 2 = ؟", options: ["3", "2", "4", "1"], answer: 0),
        Exercise.qcm(q: "ما هو العدد الذي يأتي بعد 7 ؟", options: ["8", "6", "9", "7"], answer: 0),
        Exercise.match(pairs: [
          ["2", "⭐⭐"],
          ["4", "⭐⭐⭐⭐"],
          ["1", "⭐"],
          ["5", "⭐⭐⭐⭐⭐"],
        ]),
      ],
    },
    'cp2': {
      'lecture': [
        Exercise.qcm(q: "ما هي الكلمة التي تناسب الصورة ؟ 🐱", options: ["قطة", "كلب", "عصفور", "سمكة"], answer: 0),
        Exercise.qcm(q: "أكمل : يطير الـ ___ في السماء.", options: ["عصفور", "سمك", "قطة", "كلب"], answer: 0),
        Exercise.qcm(q: "ما هي الكلمة المكتوبة بشكل صحيح ؟", options: ["مدرسة", "مدرصة", "مدرسه", "مدرصه"], answer: 0),
        Exercise.qcm(q: "أي كلمة تبدأ بنفس حرف كلمة « قطة » ؟", options: ["قلم", "كتاب", "باب", "دفتر"], answer: 0),
        Exercise.match(pairs: [
          ["قطة", "🐱"],
          ["كلب", "🐶"],
          ["عصفور", "🐦"],
          ["سمكة", "🐟"],
        ]),
      ],
      'calcul': [
        Exercise.qcm(q: "عند سارة 5 حلويات، أكلت 2. كم تبقى لها ؟", options: ["3", "2", "7", "4"], answer: 0),
        Exercise.qcm(q: "8 - 3 = ؟", options: ["5", "4", "6", "3"], answer: 0),
        Exercise.qcm(q: "4 + 4 = ؟", options: ["8", "7", "9", "6"], answer: 0),
        Exercise.qcm(q: "ما هو العدد الأكبر ؟", options: ["9", "6", "3", "1"], answer: 0),
        Exercise.match(pairs: [
          ["3+2", "5"],
          ["6-1", "5"],
          ["4+4", "8"],
          ["9-3", "6"],
        ]),
      ],
    },
  },
};

/// ---------------------------------------------------------------
/// BRAND COLORS
/// ---------------------------------------------------------------
class AppColors {
  static const bg = Color(0xFFEAF6FF);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1B2A4A);
  static const inkSoft = Color(0xFF4C5E82);
  static const lecture = Color(0xFFFF9F1C);
  static const lectureSoft = Color(0xFFFFE7C2);
  static const calcul = Color(0xFF2EC4B6);
  static const calculSoft = Color(0xFFCFF3F0);
  static const cp1 = Color(0xFFE84855);
  static const cp2 = Color(0xFF7A5CFA);
  static const success = Color(0xFF2EC4B6);
  static const error = Color(0xFFE84855);
}

/// ---------------------------------------------------------------
/// ROOT APP
/// ---------------------------------------------------------------
class TaalimApp extends StatefulWidget {
  const TaalimApp({super.key});

  @override
  State<TaalimApp> createState() => _TaalimAppState();
}

class _TaalimAppState extends State<TaalimApp> {
  String lang = 'fr';

  void setLang(String newLang) {
    setState(() => lang = newLang);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAALIM_IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.ink),
        fontFamily: 'Roboto',
      ),
      home: Directionality(
        textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: HomeScreen(lang: lang, onLangChange: setLang),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// TOP BAR (shared)
/// ---------------------------------------------------------------
class TopBar extends StatelessWidget {
  final String lang;
  final ValueChanged<String> onLangChange;

  const TopBar({super.key, required this.lang, required this.onLangChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text('📚', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            const Text(
              'TAALIM_IA',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.ink),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              _langButton('FR', 'fr'),
              _langButton('عربي', 'ar'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _langButton(String label, String code) {
    final active = lang == code;
    return GestureDetector(
      onTap: () => onLangChange(code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: active ? Colors.white : AppColors.inkSoft,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// HOME SCREEN
/// ---------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  final String lang;
  final ValueChanged<String> onLangChange;

  const HomeScreen({super.key, required this.lang, required this.onLangChange});

  @override
  Widget build(BuildContext context) {
    final s = i18n[lang]!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(lang: lang, onLangChange: onLangChange),
              const SizedBox(height: 24),
              Text(s.homeTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink)),
              const SizedBox(height: 4),
              Text(s.homeSub, style: const TextStyle(fontSize: 15, color: AppColors.inkSoft)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _LevelCard(
                      color: AppColors.cp1,
                      emoji: '🌱',
                      name: s.cp1Name,
                      hint: s.cp1Hint,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectScreen(lang: lang, onLangChange: onLangChange, level: 'cp1'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _LevelCard(
                      color: AppColors.cp2,
                      emoji: '🌟',
                      name: s.cp2Name,
                      hint: s.cp2Hint,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubjectScreen(lang: lang, onLangChange: onLangChange, level: 'cp2'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Color color;
  final String emoji;
  final String name;
  final String hint;
  final VoidCallback onTap;

  const _LevelCard({required this.color, required this.emoji, required this.name, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 14),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 38)),
              const SizedBox(height: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.white)),
              const SizedBox(height: 4),
              Text(hint, style: const TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// SUBJECT SCREEN
/// ---------------------------------------------------------------
class SubjectScreen extends StatefulWidget {
  final String lang;
  final ValueChanged<String> onLangChange;
  final String level;

  const SubjectScreen({super.key, required this.lang, required this.onLangChange, required this.level});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  String? bestLecture;
  String? bestCalcul;

  @override
  void initState() {
    super.initState();
    _loadBests();
  }

  Future<void> _loadBests() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestLecture = prefs.getString('taalim_best_${widget.lang}_${widget.level}_lecture');
      bestCalcul = prefs.getString('taalim_best_${widget.lang}_${widget.level}_calcul');
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = i18n[widget.lang]!;
    final levelName = widget.level == 'cp1' ? s.cp1Name : s.cp2Name;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(lang: widget.lang, onLangChange: widget.onLangChange),
              const SizedBox(height: 10),
              Row(
                children: [
                  _BackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  Text(levelName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink)),
                ],
              ),
              const SizedBox(height: 8),
              Text(s.chooseSubject, style: const TextStyle(fontSize: 15, color: AppColors.inkSoft)),
              const SizedBox(height: 16),
              _SubjectCard(
                color: AppColors.lectureSoft,
                emoji: '🔤',
                name: s.lecture,
                bestText: bestLecture != null ? s.best + bestLecture! : s.noScore,
                onTap: () => _openGame(context, 'lecture'),
              ),
              const SizedBox(height: 16),
              _SubjectCard(
                color: AppColors.calculSoft,
                emoji: '🔢',
                name: s.calcul,
                bestText: bestCalcul != null ? s.best + bestCalcul! : s.noScore,
                onTap: () => _openGame(context, 'calcul'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGame(BuildContext context, String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(lang: widget.lang, level: widget.level, subject: subject),
      ),
    ).then((_) => _loadBests());
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.chevron_left, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Color color;
  final String emoji;
  final String name;
  final String bestText;
  final VoidCallback onTap;

  const _SubjectCard({required this.color, required this.emoji, required this.name, required this.bestText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(bestText, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// GAME SCREEN
/// ---------------------------------------------------------------
class GameScreen extends StatefulWidget {
  final String lang;
  final String level;
  final String subject;

  const GameScreen({super.key, required this.lang, required this.level, required this.subject});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Exercise> exercises;
  int index = 0;
  int score = 0;
  int maxScore = 0;
  bool answeredCurrent = false;
  int? selectedOption;
  int? correctOption;

  // match state
  int? selectedLeftPairIndex;
  Set<int> matchedPairIndices = {};
  List<int> wrongFlashLeft = [];
  List<int> wrongFlashRight = [];
  late List<int> shuffledRightOrder;

  @override
  void initState() {
    super.initState();
    _setupExercises();
  }

  void _setupExercises() {
    exercises = content[widget.lang]![widget.level]![widget.subject]!;
    maxScore = exercises.fold(0, (sum, ex) => sum + (ex.type == 'match' ? ex.pairs!.length : 1));
    index = 0;
    score = 0;
    _setupCurrentExercise();
  }

  void _setupCurrentExercise() {
    answeredCurrent = false;
    selectedOption = null;
    correctOption = null;
    selectedLeftPairIndex = null;
    matchedPairIndices = {};
    final ex = exercises[index];
    if (ex.type == 'match') {
      final order = List<int>.generate(ex.pairs!.length, (i) => i);
      order.shuffle();
      shuffledRightOrder = order;
    }
  }

  void _answerQcm(int i) {
    if (answeredCurrent) return;
    final ex = exercises[index];
    setState(() {
      answeredCurrent = true;
      selectedOption = i;
      correctOption = ex.answer;
      if (i == ex.answer) score++;
    });
  }

  void _tapLeft(int pairIndex) {
    if (matchedPairIndices.contains(pairIndex)) return;
    setState(() => selectedLeftPairIndex = pairIndex);
  }

  void _tapRight(int pairIndex) {
    if (matchedPairIndices.contains(pairIndex) || selectedLeftPairIndex == null) return;
    if (selectedLeftPairIndex == pairIndex) {
      setState(() {
        matchedPairIndices.add(pairIndex);
        selectedLeftPairIndex = null;
        score++;
        if (matchedPairIndices.length == exercises[index].pairs!.length) {
          answeredCurrent = true;
        }
      });
    } else {
      setState(() => wrongFlashRight = [pairIndex]);
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) setState(() => wrongFlashRight = []);
      });
    }
  }

  Future<void> _next() async {
    if (!answeredCurrent) return;
    if (index < exercises.length - 1) {
      setState(() {
        index++;
        _setupCurrentExercise();
      });
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'taalim_best_${widget.lang}_${widget.level}_${widget.subject}';
    final prevBest = prefs.getInt('${key}_raw') ?? 0;
    if (score > prevBest) {
      await prefs.setInt('${key}_raw', score);
      await prefs.setString(key, '$score/$maxScore');
    }
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            lang: widget.lang,
            level: widget.level,
            subject: widget.subject,
            score: score,
            maxScore: maxScore,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = i18n[widget.lang]!;
    final levelName = widget.level == 'cp1' ? s.cp1Name : s.cp2Name;
    final subjectName = widget.subject == 'lecture' ? s.lecture : s.calcul;
    final ex = exercises[index];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _BackButton(onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 10),
                  Text('$levelName · $subjectName', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink)),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 4))],
                  ),
                  child: Text('${s.question} ${index + 1}/${exercises.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.ink)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(exercises.length, (i) {
                  Color c;
                  if (i < index) {
                    c = AppColors.success;
                  } else if (i == index) {
                    c = AppColors.ink;
                  } else {
                    c = const Color(0xFFDCE6F5);
                  }
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 8,
                      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.15), blurRadius: 34, offset: const Offset(0, 14))],
                    ),
                    child: ex.type == 'qcm' ? _buildQcm(ex, s) : _buildMatch(ex, s),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: answeredCurrent ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    index == exercises.length - 1 ? s.seeResult : s.next,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQcm(Exercise ex, Strings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ex.q!, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: List.generate(ex.options!.length, (i) {
            Color bg = Colors.white;
            Color border = const Color(0xFFE3EAF6);
            Color textColor = AppColors.ink;
            if (answeredCurrent) {
              if (i == correctOption) {
                bg = AppColors.success;
                border = AppColors.success;
                textColor = Colors.white;
              } else if (i == selectedOption) {
                bg = AppColors.error;
                border = AppColors.error;
                textColor = Colors.white;
              } else {
                bg = Colors.white.withValues(alpha: 0.45);
              }
            }
            return Material(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _answerQcm(i),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: border, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    ex.options![i],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: textColor),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        if (answeredCurrent)
          Text(
            selectedOption == correctOption ? s.correct : s.incorrect,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: selectedOption == correctOption ? AppColors.success : AppColors.error),
          ),
      ],
    );
  }

  Widget _buildMatch(Exercise ex, Strings s) {
    final pairs = ex.pairs!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${s.question} ${index + 1}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
        const SizedBox(height: 6),
        Text(s.matchInstruction, style: const TextStyle(fontSize: 14, color: AppColors.inkSoft)),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: List.generate(pairs.length, (i) {
                  final matched = matchedPairIndices.contains(i);
                  final selected = selectedLeftPairIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _matchButton(
                      label: pairs[i][0],
                      matched: matched,
                      selected: selected,
                      wrong: false,
                      onTap: () => _tapLeft(i),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: List.generate(shuffledRightOrder.length, (pos) {
                  final pairIndex = shuffledRightOrder[pos];
                  final matched = matchedPairIndices.contains(pairIndex);
                  final wrong = wrongFlashRight.contains(pairIndex);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _matchButton(
                      label: pairs[pairIndex][1],
                      matched: matched,
                      selected: false,
                      wrong: wrong,
                      onTap: () => _tapRight(pairIndex),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (answeredCurrent) Text(s.correct, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.success)),
      ],
    );
  }

  Widget _matchButton({required String label, required bool matched, required bool selected, required bool wrong, required VoidCallback onTap}) {
    Color bg = Colors.white;
    Color border = const Color(0xFFE3EAF6);
    Color textColor = AppColors.ink;
    if (matched) {
      bg = AppColors.success;
      border = AppColors.success;
      textColor = Colors.white;
    } else if (wrong) {
      bg = AppColors.error;
      border = AppColors.error;
      textColor = Colors.white;
    } else if (selected) {
      bg = const Color(0xFFEEF2FB);
      border = AppColors.ink;
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: matched ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: border, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor)),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// RESULT SCREEN
/// ---------------------------------------------------------------
class ResultScreen extends StatefulWidget {
  final String lang;
  final String level;
  final String subject;
  final int score;
  final int maxScore;

  const ResultScreen({
    super.key,
    required this.lang,
    required this.level,
    required this.subject,
    required this.score,
    required this.maxScore,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? best;

  @override
  void initState() {
    super.initState();
    _loadBest();
  }

  Future<void> _loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      best = prefs.getString('taalim_best_${widget.lang}_${widget.level}_${widget.subject}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = i18n[widget.lang]!;
    final pct = widget.maxScore > 0 ? widget.score / widget.maxScore : 0.0;
    final starCount = pct >= 0.9 ? 3 : (pct >= 0.6 ? 2 : (pct >= 0.3 ? 1 : 0));
    final stars = List.generate(3, (i) => i < starCount ? '⭐' : '·').join(' ');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.15), blurRadius: 34, offset: const Offset(0, 14))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(stars, style: const TextStyle(fontSize: 44, letterSpacing: 6)),
                  const SizedBox(height: 8),
                  Text(s.resultTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text(s.resultText(widget.score, widget.maxScore), style: const TextStyle(fontSize: 16, color: AppColors.inkSoft)),
                  if (best != null) ...[
                    const SizedBox(height: 6),
                    Text(s.best + best!, style: const TextStyle(fontSize: 13, color: AppColors.inkSoft)),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            side: const BorderSide(color: Color(0xFFE3EAF6), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(s.home, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(lang: widget.lang, level: widget.level, subject: widget.subject),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(s.retry, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
