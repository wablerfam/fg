import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  Offset _buttonPosition = const Offset(100, 100);

  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You have pushed the button this many times:'),
                Text(
                  '$counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          Positioned(
            left: _buttonPosition.dx,
            top: _buttonPosition.dy,
            child: Draggable<String>(
              data: 'button',
              feedback: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
              childWhenDragging: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.grey,
                child: const Icon(Icons.add),
              ),
              onDragEnd: (details) {
                setState(() {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.offset);
                  _buttonPosition = localPosition;
                });
              },
              child: FloatingActionButton(
                onPressed: () => ref.read(counterProvider.notifier).increment(),
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
