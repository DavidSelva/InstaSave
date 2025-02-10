import 'package:flutter/material.dart';
import 'package:instasave/controller/get_web_view_controller.dart';
import 'package:instasave/mainfragment/downloads_fragment.dart';
import 'package:instasave/mainfragment/home_fragment.dart';
import 'package:instasave/utils/pref_utils.dart';
import 'package:get/get.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaSave',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'InastaSave'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageController _pageViewController;
  int bottomSelectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageViewController = PageController();
    PrefUtils.init();
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: _handlePageViewChanged,
        children: const <Widget>[HomeFragment(), DownloadFragment()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: buildBottomNavBarItems(),
        backgroundColor: Colors.blueAccent,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.jumpToPage(index);
    });
  }

  void _handlePageViewChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }
}

List<BottomNavigationBarItem> buildBottomNavBarItems() {
  return [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'InstaSave'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.download), label: 'Downloads'),
  ];
}

PageController pageController = PageController(
  initialPage: 0,
  keepPage: true,
);
