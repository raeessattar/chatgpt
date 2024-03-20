import 'dart:io';

import 'package:chatgpt/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

///
///to store value of multiple response we will make list of responses
///and print the list
///there will be two lists one of myController and second of data
///then print one by one

String? apiKey;
const String roleUser = 'user';
const String roleChatGPT = 'chatgpt';
bool generatingResponse = false;

void main() async {
  await dotenv.load(fileName: ".env");
  apiKey = dotenv.env["API_KEY"];

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat GPT App',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(172, 134, 2, 2)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Chat GPT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Conversation> conversation = [];
  final myController = TextEditingController();
  ChatGPT? data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (data?.message.content == null)
            Text('')
          else
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                  itemCount: conversation.length,
                  itemBuilder: ((context, index) {
                    return Card(
                      color: conversation[index].role == roleUser
                          ? Theme.of(context)
                              .colorScheme
                              .inversePrimary //Color(0x89ABE3FF)
                          : Theme.of(context)
                              .colorScheme
                              .onPrimary, //Color(0xFCF6F5FF),
                      margin: conversation[index].role == roleUser
                          ? EdgeInsets.only(left: 100, top: 10)
                          : EdgeInsets.only(right: 100, top: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          textAlign: TextAlign.left,
                          conversation[index].response,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Open Sans',
                          ),
                        ),
                      ),
                    );
                  })),
            )),
          if (generatingResponse)
            Text(
              'Generating Response',
              style: TextStyle(
                color: Colors.grey[800],
                fontStyle: FontStyle.italic,
                fontFamily: 'Open Sans',
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'How may I help you?',
                    ),
                    controller: myController,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: ElevatedButton(
                  child: const Text('Go'),
                  onPressed: () async {
                    //check the data in text field if the data is enetered
                    if (myController.text == '') {
                      return null;
                    } else {
                      conversation.add(
                          Conversation.fromJson(roleUser, myController.text));
                      setState(() {
                        //calling setState for showing sent message and displaying
                        // the generating response value
                        generatingResponse = true;
                      });

                      data = await fetchData(myController.text, apiKey);
                      conversation.add(Conversation.fromJson(
                          roleChatGPT, data!.message.content));

                      //checking null value, then making flag true & when data
                      // is not null we call setState and making flag false again
                      if (data?.message.content != 'null')
                        setState(() {
                          generatingResponse = false;
                          myController.clear();
                        });
                    }
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
