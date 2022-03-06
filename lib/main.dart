import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ondemandservice/ui/main.dart';
import 'package:ondemandservice/ui/splash.dart';
import 'model/localSettings.dart';
import 'strings.dart';
import 'package:provider/provider.dart';

import 'model/model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await getTheme();
  await getLocalSettings();

  // User? user = FirebaseAuth.instance.currentUser;
  // final User? user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //         email: "o1@m.ru", password: "123456",)).user;
  // if (user != null)
  //   FirebaseFirestore.instance.collection("listusers").doc(user.uid).set({
  //     // "role": "owner" ,
  //     "visible": true,
  //     "providerApp": true,
  //     "providerRequest" : true,
  //     "phoneVerified": false,
  //     "email": user.email,
  //     "phone": "",
  //     "name": "name",
  //     "date_create" : FieldValue.serverTimestamp()
  //   }, SetOptions(merge:true));

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainModel()),
        ChangeNotifierProvider(create: (_) => LanguageChangeNotifierProvider()),
      ],
      child: OnDemandApp()
  ));
}

class OnDemandApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: strings.get(0),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('it'),
        const Locale('de'),
        const Locale('es'),
        const Locale('fr'),
        const Locale('ar'),
        const Locale('pt'),
        const Locale('ru'),
        const Locale('hi'),
      ],
      locale: Provider.of<LanguageChangeNotifierProvider>(context, listen: true).currentLocale,
      theme: ThemeData(
        //fontFamily: "Tajawal",
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/splash',
      routes: {
        //
        // On Demand Home Service
        //
        '/splash': (BuildContext context) => SplashScreen(),
        '/ondemandservice_main': (BuildContext context) => MainScreen(),
      },
    );
  }
}

class LanguageChangeNotifierProvider with ChangeNotifier, DiagnosticableTreeMixin {

  Locale  _currentLocale = new Locale(strings.locale);

  Locale get currentLocale => _currentLocale;

  void changeLocale(String _locale){
    this._currentLocale = new Locale(_locale);
    notifyListeners();
  }
}