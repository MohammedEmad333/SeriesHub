import 'package:flutter/material.dart';

import '../../../core/providers/provider_registry.dart';
import '../../../core/providers/remote_provider_repository.dart';

class ProviderManagerScreen extends StatefulWidget {
  const ProviderManagerScreen({
    super.key,
    required this.registry,
  });

  final ProviderRegistry registry;

  @override
  State<ProviderManagerScreen> createState() => _ProviderManagerScreenState();
}

class _ProviderManagerScreenState extends State<ProviderManagerScreen> {
  bool _refreshing = false;
  String? _message;

  Future<void> _refresh() async {
    if (_refreshing) return;

    setState(() {
      _refreshing = true;
      _message = null;
    });

    final index = await RemoteProviderRepository().load();

    if (!mounted) return;

    if (index == null) {
      setState(() {
        _refreshing = false;
        _message = 'تعذر تحديث المستودع. تم الاحتفاظ بالمصادر الحالية.';
      });
      return;
    }

    widget.registry.applyRemoteIndex(index);

    setState(() {
      _refreshing = false;
      _message = 'تم تحديث المصادر.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.registry,
      builder: (context, _) {
        final known = widget.registry.known
            .where((provider) => provider.id != 'mock')
            .toList(growable: false);
        final activeIds =
            widget.registry.all.map((provider) => provider.id).toSet();

        return Scaffold(
          appBar: AppBar(
            title: const Text('المصادر'),
            actions: [
              IconButton(
                tooltip: 'تحديث المصادر',
                onPressed: _refreshing ? null : _refresh,
                icon: _refreshing
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined),
                  title: const Text('SeriesHub Providers'),
                  subtitle: const Text(
                    'تُحدَّث حالة وترتيب المصادر من المستودع الرسمي على GitHub.',
                  ),
                  trailing: Text('${known.length} مصادر'),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 8),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              for (final provider in known)
                _ProviderTile(
                  name: provider.name,
                  descriptor: widget.registry.metadataFor(provider.id),
                  active: activeIds.contains(provider.id),
                ),
              const Divider(height: 32),
              const ListTile(
                leading: Icon(Icons.science_outlined),
                title: Text('بيانات تجريبية'),
                subtitle: Text(
                  'مصدر محلي للاختبارات ولا يتحكم به المستودع البعيد.',
                ),
                trailing: Icon(Icons.check_circle_outline),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.name,
    required this.descriptor,
    required this.active,
  });

  final String name;
  final RemoteProviderDescriptor? descriptor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final status = descriptor?.status;
    final playback = descriptor?.playback ?? false;

    final (label, icon) = switch (status) {
      'working' when playback => ('تشغيل متاح', Icons.play_circle_outline),
      'metadata_only' => ('بيانات فقط', Icons.info_outline),
      'experimental' => ('تجريبي', Icons.science_outlined),
      'broken' => ('متوقف مؤقتًا', Icons.error_outline),
      'disabled' => ('معطل', Icons.block_outlined),
      _ => ('محلي', Icons.storage_outlined),
    };

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(name),
        subtitle: Text(label),
        trailing: Icon(
          active ? Icons.check_circle : Icons.remove_circle_outline,
        ),
      ),
    );
  }
}
