import 'package:flutter/material.dart';
import 'package:swardenapp/app/core/constants/colors.dart';
import 'package:swardenapp/app/core/extensions/num_to_sizedbox_extensions.dart';
import 'package:swardenapp/app/presentation/global/dialogs/dialogs.dart';
import '../../../../domain/models/entry_model.dart';

class EntryTileWidget extends StatelessWidget {
  final EntryDataModel entry;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EntryTileWidget({
    super.key,
    required this.entry,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.lock, color: Colors.white),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            5.h,

            Row(
              children: [
                Icon(Icons.storage, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  entry.createdAt.toIso8601String().split('T').first,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.settings),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                onEdit?.call();
                break;
              case 'delete':
                final confirm = await SwardenDialogs.dialog(
                  context: context,
                  title: 'Confirmar eliminació',
                  content: Text(
                    'Estàs segur que vols eliminar aquesta entrada?',
                  ),
                );
                if (!confirm) return;
                onDelete?.call();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Eliminar', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
