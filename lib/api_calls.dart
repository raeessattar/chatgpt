
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<ChatGPT> fetchData(String query, String? api_key) async {
  Map<String, String> gptHeaders = {
    'Authorization': 'Bearer $api_key',
    'content-type': 'application/json'
  };
  Map<String, dynamic> gptBody = {
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "user", "content": "$query"}
    ]
  };

  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    body: jsonEncode(gptBody),
    headers: gptHeaders,
  );

  print(response.body);
  return ChatGPT.fromJson(jsonDecode(response.body));
}





class ChatGPT {
  final String object;
  final ChatGPTmessage message;

  const ChatGPT({required this.object, required this.message});

  factory ChatGPT.fromJson(Map<String, dynamic> map) {
    return ChatGPT(
      object: map['object'],
      message: (map['choices'])
          .map<ChatGPTmessage>((e) => ChatGPTmessage.fromJson(e['message']))
          .toList()[0],
    );
  }
}

class ChatGPTmessage {
  final String role;
  final String content;

  const ChatGPTmessage({required this.role, required this.content});

  factory ChatGPTmessage.fromJson(Map<String, dynamic> map) {
    return ChatGPTmessage(role: map['role'], content: map['content']);
  }
}



// {
//     "id": "chatcmpl-91UxBX4nH4Ymi2UR4TgTlNpmuYTx3",
//     "object": "chat.completion",
//     "created": 1710144341,
//     "model": "gpt-3.5-turbo-0125",
//     "choices": [
//         {
//             "index": 0,
//             "message": {
//                 "role": "assistant",
//                 "content": "The recent FIFA World Cup was held in 2018 and was won by the French national football team."
//             },
//             "logprobs": null,
//             "finish_reason": "stop"
//         }
//     ],
//     "usage": {
//         "prompt_tokens": 16,
//         "completion_tokens": 21,
//         "total_tokens": 37
//     },
//     "system_fingerprint": "fp_4f0b692a78"
// }


