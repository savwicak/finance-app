import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:get/get.dart';
import 'package:nvidiaapp/core/app_routes.dart';
import 'package:nvidiaapp/core/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
=======
import 'package:nvidiaapp/presentation/screens/splash/splash_screen.dart';
>>>>>>> 4d363e7 (feat: splash screen, onboarding, apptheme)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: Routes.login,
      getPages: Routes.pages
    );
  }
}
=======
    return MaterialApp(
      title: "Nvidia App",
      debugShowCheckedModeBanner: false,
      // theme: AppTheme.theme,
      home: SplashScreen(),
    );
  }
}
>>>>>>> 4d363e7 (feat: splash screen, onboarding, apptheme)
