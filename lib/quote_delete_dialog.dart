import 'package:flutter/material.dart';

import 'main.dart';
import 'models/quote.dart';
import 'models/responses.dart';

class  QuoteDeleteDialog extends StatelessWidget{
  final String token;
  final Quote quote;
  final Function(QuoteActionResponse)? onDone;

  const QuoteDeleteDialog({required this.token, required this.quote, this.onDone, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      content: const Text("Really?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Nope"),
        ),
        ElevatedButton(
          onPressed: () {
            api.deleteQuote(
              token: token,
              quote: quote
            ).then((e){
              if(onDone != null) onDone!(e);
            });
            Navigator.pop(context);
          },
          child: const Text("(Thanos snaps)")
        )
      ],
    );
  }
}
