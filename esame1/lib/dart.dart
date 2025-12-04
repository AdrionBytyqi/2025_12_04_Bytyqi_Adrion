class Exercise {
  String name;
  int score;
  DateTime submittedAt;

  Exercise({
    required this.name,
    required this.score,
    required this.submittedAt,
  });

  bool get isPassed {
    return score >= 60;
  }
}

List<Exercise> passedOnly(List<Exercise> exercises) {
  List<Exercise> results = [];
  
  for (var i=0; i < exercises.length; i++) {
    if (exercises[i].isPassed) {
      results.add(exercises[i]);
    }
  }
  
  return results;
}

double averageScore(List<Exercise> exercises) {
  if (exercises.isEmpty) {
    return 0;
  }

  double total = 0;
  
  for (var i=0; i< exercises.length; i++) {
    total = total + exercises[i].score;
  }

  return total / exercises.length;
}

String bestStudent(List<Exercise> exercises) {
  if (exercises.isEmpty) {
    return "";
  }

  Exercise best = exercises[0];

  for (var i=0; i < exercises.length; i++) {
    if (exercises[i].score > best.score) {
      best = exercises[i];
    }
  }

  return best.name;
}

void main() {
  List<Exercise> list = [
    Exercise(name: "mario", score: 85, submittedAt: DateTime.now()),
    Exercise(name: "dario", score: 60, submittedAt: DateTime.now()),
    Exercise(name: "paolo", score: 10, submittedAt: DateTime.now())
  ];
  print(passedOnly(list).length);
  print(averageScore(list));
  print(bestStudent(list));
}