import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  runApp(
    ProviderScope(
      observers: [
        TalkerRiverpodObserver(
          settings: const TalkerRiverpodLoggerSettings(
            printProviderDisposed: true,
          ),
        ),
      ],
      retry: (retryCount, error) {
        return null;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 94, 123),
        ),
        useMaterial3: true,
      ),
      home: const ReviewsPage(),
    );
  }
}

class Review {
  String title;
  String? comment;
  int rating;

  Review({
    required this.title,
    this.comment,
    required this.rating,
  });
}

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final List<Review> _reviews = [
    Review(title: "Pizzeria", rating: 5, comment: "bel posto"),
    Review(title: "Ostera", rating: 3, comment: "ottimo"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyFork"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: _reviews.length,
        itemBuilder: (context, index) {
          final review = _reviews[index];
          return ListTile(
            title: Text(review.title),
            subtitle: Text("Voto: ${review.rating}\n${review.comment ?? ''}"),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openForm(review, index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(null, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openForm(Review? existingReview, int? index) async {
    final Map<String, Object?>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewFormPage(reviewToEdit: existingReview),
      ),
    );

    if (result != null) {
      final newReview = Review(
        title: result['title'] as String,
        comment: result['comment'] as String?,
        rating: result['rating'] as int,
      );

      setState(() {
        if (index != null) {
          _reviews[index] = newReview;
        } else {
          _reviews.add(newReview);
        }
      });
    }
  }
}

class ReviewFormPage extends StatefulWidget {
  final Review? reviewToEdit;

  const ReviewFormPage({super.key, this.reviewToEdit});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  late FormGroup _form;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'title': FormControl<String>(
        value: widget.reviewToEdit?.title ?? '',
        validators: [Validators.required],
      ),
      'comment': FormControl<String>(
        value: widget.reviewToEdit?.comment,
      ),
      'rating': FormControl<int>(
        value: widget.reviewToEdit?.rating ?? 1,
        validators: [
          Validators.required,
          Validators.min(1),
          Validators.max(5),
        ],
      ),
    });
  }

  void _save() {
    if (_form.valid) {
      final data = {
        'title': _form.control('title').value,
        'comment': _form.control('comment').value,
        'rating': _form.control('rating').value,
      };
      Navigator.pop(context, data);
    } else {
      _form.markAllAsTouched();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reviewToEdit == null ? "Nuova Recensione" : "Modifica"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: _form,
          child: Column(
            children: [
              ReactiveTextField(
                formControlName: 'title',
                decoration: const InputDecoration(
                  labelText: 'Nome Ristorante',
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  ValidationMessage.required: (_) => 'Titolo',
                },
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'comment',
                decoration: const InputDecoration(
                  labelText: 'Commento (opzionale)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ReactiveTextField(
                formControlName: 'rating',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Voto (1-5)',
                  border: OutlineInputBorder(),
                ),
                validationMessages: {
                  ValidationMessage.min: (_) => 'Minimo 1',
                  ValidationMessage.max: (_) => 'Massimo 5',
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text("Salva"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}