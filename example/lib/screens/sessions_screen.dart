import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:trainingkit_flutter/trainingkit_flutter.dart';

import '../graphql/queries.dart';

/// Lists the demo workouts, grouped by format, and launches the native
/// TrainingKit experience when one is tapped.
class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  static const routeName = '/sessions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes séances')),
      body: Query(
        options: QueryOptions(document: gql(getSessions)),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading && result.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(result.exception.toString()),
              ),
            );
          }

          final edges =
              (result.data?['publicWorkouts']?['edges'] as List?) ?? const [];
          final nodes = edges
              .map((edge) => (edge as Map)['node'] as Map<String, dynamic>)
              .toList();

          final classic = nodes
              .where((node) => node['format'] == 'CLASSIC')
              .toList();
          final streaming = nodes
              .where((node) => node['format'] == 'PLAY')
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              _SectionHeader('Séances classiques'),
              ...classic.map((node) => _WorkoutTile(node: node)),
              _SectionHeader('Séances en streaming'),
              ...streaming.map((node) => _WorkoutTile(node: node)),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 20, 36, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({required this.node});

  final Map<String, dynamic> node;

  String get _duration {
    final seconds = (node['duration'] as num?)?.toInt() ?? 0;
    return '${seconds ~/ 60} min';
  }

  @override
  Widget build(BuildContext context) {
    final picture = node['picture'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: picture == null
                ? const ColoredBox(color: Color(0x11000000))
                : Image.network(picture, fit: BoxFit.cover),
          ),
        ),
        title: Text(
          node['name'] as String? ?? '',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_duration),
        onTap: () => _launch(context, node['id'] as String),
      ),
    );
  }

  Future<void> _launch(BuildContext context, String id) async {
    final client = GraphQLProvider.of(context).value;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await client.query(
        QueryOptions(
          document: gql(getSessionContent),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final session = result.data?['publicWorkoutSession'];
      if (session is! Map<String, dynamic>) {
        throw const TrainingKitException('Workout session not found.');
      }

      await launchWorkout(session);
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Erreur : $error')));
    }
  }
}
