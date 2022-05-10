import 'dart:developer';
import 'dart:io';
import 'package:cobrowse_flutter_app/about_screen.dart';
import 'package:cobrowse_flutter_app/workaround_method_channel.dart';
import 'package:cobrowseio_flutter/cobrowseio_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initCobrowse();
    // WorkaroundCobrowsePlugin.instance.listenToAgentRemoteActions();
  }

  void initCobrowse() async {
    CobrowseIO.start("<KEY>", {'username': 'TestUser'});

    log(await CobrowseIO.getCode());

    // Enable full access control on Android.
    if (Platform.isAndroid) {
      if (!await CobrowseIO.accessibilityServiceIsRunning()) {
        CobrowseIO.accessibilityServiceOpenSettings();
      }

      CobrowseIO.accessibilityServiceShowSetup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: _HomeScreen(),
        ));
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(title: const Text('Co-browse.io Example'), actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => AboutScreen()));
                },
                icon: const Icon(Icons.question_mark_rounded))
          ]),
          body: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Type in here', label: Text('TextField')),
                  ),
                ),
              ),
              const _SliverHeader(
                title: 'Horizontal List',
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        height: 150,
                        width: 60,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.grey),
                      );
                    },
                    scrollDirection: Axis.horizontal,
                    itemCount: 60,
                  ),
                ),
              ),
              const _SliverHeader(
                title: 'Vertical List',
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ListTile(
                      title: Text('Item number $index'),
                    );
                  },
                  childCount: 100,
                ),
              )
            ],
          )),
    );
  }
}

class _SliverHeader extends StatelessWidget {
  final String title;
  const _SliverHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
        ),
      ),
    );
  }
}
