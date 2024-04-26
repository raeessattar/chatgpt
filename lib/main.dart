import 'dart:async';

import 'package:chatgpt/database_singleton.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:chatgpt/api_calls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

///
///1: we will make a new column in the table
///2: where each chat room will have unique number
///3: we will make counter that will incremented after each time app oppened
///4: this incremented value will be assign to the conversation number
///5: the data will store in the same table, but with different chatnumber
///6: when the app is loaded, last conversation will also be opened

String? apiKey;
const String roleUser = 'user';
const String roleChatGPT = 'chatgpt';
bool generatingResponse = false;

//final database;
//instace of data base;
late LocalDatabase? instanceDatabase;

List<Conversation> conversation = [];
Set idSet = {};
List<dynamic> idNumbers = [];
int currentId = 1;

void main() async {
  await dotenv.load(fileName: ".env");
  apiKey = dotenv.env["API_KEY"];

  //this is used in Sqflite tutorial
  WidgetsFlutterBinding.ensureInitialized();

  //local data base singleton class
  instanceDatabase = await LocalDatabase.initialize();

  runApp(const MyApp());
}

///
///
///
///
///
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat GPT App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
            secondary: Colors.blue),
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
  final myController = TextEditingController();
  ChatGPT? data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      List<Conversation> conv =
          await instanceDatabase!.retrieveData(); // retrieveData();
      //getting unique number
      for (var e in conv) {
        idSet.add(e.id);
      }
      idNumbers = idSet.toList();
      //-1 for recent current conversation
      //and by default last chat
      if (idNumbers.isEmpty) {
        conversation = await instanceDatabase!.retrieveHistoryData(
            idNumbers.length); //retrieveHistoryData(idNumbers.length);
        currentId = idNumbers.length;
      } else if (idNumbers.isNotEmpty) {
        conversation = await instanceDatabase!.retrieveHistoryData(
            idNumbers.length - 1); //retrieveHistoryData(idNumbers.length - 1);
        currentId = idNumbers.length - 1;
      }

      // print(
      //     'id number length is ${idNumbers.length} and conv length is ${conversation.length}');
      // for (int i = 0; i < conve rsation.length; i++) {
      //   print(
      //       '${conversation[i].id}  ${conversation[i].role}  ${conversation[i].response}');
      // }

      setState(() {});
    }); //initstate()
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                conversation = await instanceDatabase!.retrieveHistoryData(
                    idNumbers.length); //retrieveHistoryData(idNumbers.length);
                currentId = idNumbers.length;
                idSet.add(idNumbers.length);
                idNumbers = idSet.toList();
                setState(() {});
              })
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  height: 10,
                  child: const Text(
                    'History',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                )),

            ListView.builder(
                shrinkWrap: true,
                itemCount: idNumbers.length,
                itemBuilder: (((context, index) {
                  return ListTile(
                    title: Text('conversation no: ${idNumbers[index] + 1}'),
                    onTap: () async {
                      conversation = await instanceDatabase!
                          .retrieveHistoryData(idNumbers[
                              index]); //retrieveHistoryData(idNumbers[index]);
                      currentId = idNumbers[index];
                      setState(() {});
                      //check if the context is mounted or not
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                })))
            // ListTile(
            //   title: Text('${idNumbers.length}'),
            //   onTap: () {
            //     //ontap code
            //   },
            // )
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (conversation.isEmpty) //data?.message.content == null
            const Text('')
          else
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                reverse: true,
                child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                            ? const EdgeInsets.only(
                                left: 100, right: 5, top: 5, bottom: 5)
                            : const EdgeInsets.only(
                                right: 100, left: 5, top: 5, bottom: 5),
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
              ),
            )),
          //SizedBox(height: 10,),
          if (generatingResponse)
            Text(
              'Generating Response...',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'How may I help you?',
                    ),
                    controller: myController,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: ElevatedButton(
                  child: const Text('Go'),
                  onPressed: () async {
                    //check the data in text field if the data is enetered
                    if (myController.text == '') {
                      return;
                    } else {
                      conversation.add(Conversation(
                          id: currentId,
                          role: roleUser,
                          response: myController.text));
                      setState(() {
                        //calling setState for showing sent message and displaying
                        // the generating response value
                        generatingResponse = true;
                      });

                      data = await fetchData(myController.text, apiKey);
                      conversation.add(Conversation(
                          id: currentId,
                          role: roleChatGPT,
                          response: data!.message.content));
                      //checking null value, then making flag true & when data
                      // is not null we call setState and making flag false again
                      if (data?.message.content != 'null') {
                        generatingResponse = false;
                        setState(() {});
                      }

                      //inserting data to the local memory
                      await instanceDatabase!.insertData(Conversation(
                          id: currentId,
                          role: roleUser,
                          response: myController.text));
                      //  insertData(Conversation(
                      //     id: currentId,
                      //     role: roleUser,
                      //     response: myController.text));
                      await instanceDatabase!.insertData(Conversation(
                          id: currentId,
                          role: roleChatGPT,
                          response: data!.message.content));
                      // insertData(Conversation(
                      //     id: currentId,
                      //     role: roleChatGPT,
                      //     response: data!.message.content));
                      myController.clear();
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
