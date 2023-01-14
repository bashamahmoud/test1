import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
Future<void> backgroundhandler(RemoteMessage message) async {
  print('backgroundhandler the ${message.messageId}');
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(backgroundhandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String? mtoken = " ";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  TextEditingController username= TextEditingController();
  TextEditingController title= TextEditingController();
  TextEditingController body= TextEditingController();
  @override
  void initState(){
    print('hi');
    super.initState();
    requestPermission();
    getToken();
    getInfo();

  }
  void requestPermission()async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print(settings.authorizationStatus);
    if (settings.authorizationStatus == AuthorizationStatus.authorized){
      print('granted');

    }
    else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print('provisional');
    }
    else if(settings.authorizationStatus == AuthorizationStatus.notDetermined){
      pragma("not determined");
    }
    else{
      print('denied');
    }
  }
  void getToken()async{
    await FirebaseMessaging.instance.getToken().then(
      (token) {
        setState((){
          mtoken = token;
          print("my token is $token");
        });
        saveToken(token!);
      }
      );
    
  }
  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("user token").doc("user1").set({
      'token' : token,
    });
  }
  void getInfo(){
    var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationsSetteings = InitializationSettings(android: androidInitialize);
    flutterLocalNotificationsPlugin.initialize(initializationsSetteings, onDidReceiveNotificationResponse: onNotificationResponse);
    FirebaseMessaging.onMessage.listen((RemoteMessage message)async {
      print("onmessage:${message.notification?.title}/${message.notification?.body}");
      BigTextStyleInformation bigTextStyleInformation =  BigTextStyleInformation(
        message.notification!.body.toString(),htmlFormatBigText: true,
        contentTitle: message.notification!.title.toString(),htmlFormatContentTitle: true,);
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'dbfood','dbfood', importance: Importance.high,styleInformation: bigTextStyleInformation,priority: Priority.high,playSound: true,
      );
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(0,message.notification?.title,message.notification?.body,platformChannelSpecifics,
      payload: message.data['body']);
     });
  }

void onNotificationResponse(NotificationResponse response) {
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("response.notification.title"),
        content: Text(""),
        actions: <Widget>[
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
  




  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             TextFormField(
              controller: username,
             ),
              TextFormField(
              controller: title,
             ),
              TextFormField(
              controller: body,
             ),
             GestureDetector(
              onTap: () async {
                String name = username.text.trim();
                String titleText = title.text;
                String bodyText = body.text;

              },
              child: Container(
                margin: const EdgeInsets.all(20),
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.5),
                    )
                  ]

                ),
                child: Center(child: const Text("Button"),),
              )
             )
         // This trailing comma makes auto-formatting nicer for build methods.
    ]),
      
    ),
    );
  }
}
