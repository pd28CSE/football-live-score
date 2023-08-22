import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Football Live Score',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matche List'),
      ),
      body: StreamBuilder(
        stream: firestore.collection('footballmatches').snapshots(),
        builder: (cntxt, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError == true) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData && snapshot.data?.docs.isEmpty == true) {
            return const Center(child: Text('No Match.'));
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            // log(snapshot.data!.docs.length.toString());
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (cntxt, index) {
                return ListTile(
                  title: Text(
                      '${snapshot.data!.docs[index].get('team_a')} vs ${snapshot.data!.docs[index].get('team_b')}'),
                  trailing: const Icon(Icons.arrow_right_alt_outlined),
                  onTap: () {
                    navigateToMatchDetailsScreen(snapshot.data!.docs[index].id);
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void navigateToMatchDetailsScreen(String matchId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (cntxt) => MatchDetails(
          matchId: matchId,
        ),
      ),
    );
  }
}

class MatchDetails extends StatelessWidget {
  final String matchId;
  MatchDetails({super.key, required this.matchId});

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(matchId),
      ),
      body: StreamBuilder(
        stream:
            firestore.collection('footballmatches').doc(matchId).snapshots(),
        builder: (cntxt, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError == true) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData && snapshot.data!.exists == false) {
            return const Center(child: Text('No Match.'));
          } else if (snapshot.hasData) {
            // log(snapshot.data!.data().toString());
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                child: SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "${snapshot.data!.get('team_a')} vs ${snapshot.data!.get('team_b')}",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          "${snapshot.data!.get('score_team_a')} : ${snapshot.data!.get('score_team_b')}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Time : ${snapshot.data!.get('time')}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Total Time : ${snapshot.data!.get('total_time')}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
