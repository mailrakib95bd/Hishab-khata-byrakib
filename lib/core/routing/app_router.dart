import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// GoRouter প্রোভাইডার যা অ্যাপের রাউটিং কাঠামো নিয়ন্ত্রণ করবে।
/// PRD এবং ফ্লাটার ক্লিন আর্কিটেকচার অনুযায়ী রাউটগুলো এখানে ডিফাইন করা হবে।
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text(
              'হিসাব খাতা BD - হোম পেজ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ],
  );
});
