import 'package:flutter/material.dart';

import '../models/upi_app.dart';

Future<UpiApp?> showUpiAppPickerBottomSheet(
  BuildContext context, {
  required List<UpiApp> apps,
  String title = 'Select UPI App',
  Color? backgroundColor,
}) {
  return showModalBottomSheet<UpiApp>(
    context: context,
    backgroundColor: backgroundColor,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: apps.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return ListTile(
                    leading: _UpiAppIcon(app: app),
                    title: Text(app.name),
                    subtitle: Text(app.identifier),
                    onTap: () => Navigator.of(context).pop(app),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _UpiAppIcon extends StatelessWidget {
  const _UpiAppIcon({required this.app});

  final UpiApp app;

  @override
  Widget build(BuildContext context) {
    if (app.icon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          app.icon!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      );
    }
    return CircleAvatar(
      radius: 18,
      child: Text(
        app.name.isNotEmpty ? app.name[0].toUpperCase() : '?',
      ),
    );
  }
}
