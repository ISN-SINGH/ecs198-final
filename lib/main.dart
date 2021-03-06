import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:testing/app.dart';
import 'package:testing/firebase_user_object.dart';
import 'package:testing/sign_in_page.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  

  FirebaseFirestore _db = FirebaseFirestore.instance;

  runApp(MyApp(db: _db));
}

class MyApp extends StatelessWidget {
  final FirebaseFirestore db;

  const MyApp({Key? key, required this.db}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Home(db: db),
    );
  }
}

class Home extends StatefulWidget {
  final FirebaseFirestore db;
  
  const Home({Key? key, required this.db}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const SignInPage();
    }

    final userRef = widget.db.collection("users").doc(_user!.email)
      .withConverter(fromFirestore: UserObj.fromFirestore, toFirestore: (UserObj userObj, _) => userObj.toFirestore());

    return FutureBuilder( // first future builder to check if user exists
      future: userRef.get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot<UserObj>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.exists) {
            print("user ${_user!.email} in database");
            return App(user: _user!, db: widget.db);
          } else {
            final userObj = UserObj.simple(_user!.displayName, _user!.email, _user!.photoURL);
            return FutureBuilder( // add user to db
              future: userRef.set(userObj),
              builder: (context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) { // user added to db
                  print("user ${_user!.email} added to database");
                  return App(user: _user!, db: widget.db);
                }
                return Container();
              },
            );
          }
        }
        return Container();
      },
    );

    userRef.get().then((docSnapshot) async {
      if (docSnapshot.exists) {
        print("user ${_user!.email} in database");
      } else {
        final userObj = UserObj.simple(_user!.displayName, _user!.email, _user!.photoURL);
        await userRef.set(userObj); // create the user
        print("user ${_user!.email} added to database");
      }
    });

    // Above method may be better
    // final userInfo = {"name": _user!.displayName, "email": _user!.email, "photoUrl": _user!.photoURL};
    // widget.db
    //     .collection("users")
    //     .doc(_user!.email)
    //     .set(userInfo, SetOptions(merge: true))
    //     .then((value) => print("user ${_user!.email} in database"));

    return App(user: _user!, db: widget.db);
  }
}

