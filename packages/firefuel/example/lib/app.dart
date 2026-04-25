import 'package:flutter/material.dart';

import 'package:firefuel_example/playground/playground.dart';

class FirefuelPlaygroundApp extends MaterialApp {
  const FirefuelPlaygroundApp({super.key})
      : super(
          debugShowCheckedModeBanner: false,
          home: const PlaygroundPage(),
        );
}
