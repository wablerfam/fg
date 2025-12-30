import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GridNotifier extends Notifier<List<String?>> {
  @override
  List<String?> build() => [
    'W', null, null, null,
    null, 'T', null, null,
    null, null, null, null,
  ];

  void moveBlock(int fromIndex, int toIndex) {
    if (fromIndex == toIndex) return;
    if (state[toIndex] != null) return;

    final newState = [...state];
    newState[toIndex] = newState[fromIndex];
    newState[fromIndex] = null;
    state = newState;
  }
}

final gridProvider = NotifierProvider<GridNotifier, List<String?>>(
  GridNotifier.new,
);

class ConsoleNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addMessage(String message) {
    state = [...state, message];
  }

  void clear() {
    state = [];
  }
}

final consoleProvider = NotifierProvider<ConsoleNotifier, List<String>>(
  ConsoleNotifier.new,
);

const Map<String, String> blockCommands = {
  'W': 'weather',
  'T': 'test',
};

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Layout Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 15,
            child: HeaderSection(),
          ),
          Expanded(
            flex: 35,
            child: ConsoleSection(),
          ),
          Expanded(
            flex: 35,
            child: BlockSection(),
          ),
          Expanded(
            flex: 15,
            child: FooterSection(),
          ),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Center(
        child: Text(
          'Header (15%)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

class ConsoleSection extends ConsumerWidget {
  const ConsoleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(consoleProvider);

    return Container(
      width: double.infinity,
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: messages.isEmpty
          ? Center(
              child: Text(
                'Console',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.greenAccent.withValues(alpha: 0.5),
                ),
              ),
            )
          : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Text(
                  messages[index],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Colors.greenAccent,
                  ),
                );
              },
            ),
    );
  }
}

class BlockSection extends ConsumerWidget {
  const BlockSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridData = ref.watch(gridProvider);

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight * 2 / 3;
          final cellSize = availableHeight / 3;
          final gridWidth = cellSize * 4;
          return Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: gridWidth,
              height: availableHeight,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final label = gridData[index];

                  if (label != null) {
                    return DraggableBlockButton(label: label, index: index);
                  } else {
                    return DropTargetDot(index: index);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class DraggableBlockButton extends ConsumerWidget {
  const DraggableBlockButton({
    super.key,
    required this.label,
    required this.index,
  });

  final String label;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Draggable<int>(
      data: index,
      feedback: Material(
        elevation: 4,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        ),
      ),
      child: DragTarget<int>(
        onAcceptWithDetails: (details) {
          ref.read(gridProvider.notifier).moveBlock(details.data, index);
        },
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () {
              final command = blockCommands[label];
              if (command != null) {
                ref.read(consoleProvider.notifier).addMessage(command);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DropTargetDot extends ConsumerWidget {
  const DropTargetDot({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        ref.read(gridProvider.notifier).moveBlock(details.data, index);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          decoration: isHovering
              ? BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  color: Theme.of(context).colorScheme.primaryContainer,
                )
              : null,
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Center(
        child: Text(
          'Footer (15%)',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
