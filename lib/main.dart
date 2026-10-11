import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ফায়ারবেস ইনিশিয়ালাইজেশনের কোড এখানে পরবর্তীতে যুক্ত হবে
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      child: HishabKhataApp(),
    ),
  );
}
