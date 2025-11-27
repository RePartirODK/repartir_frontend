import 'package:flutter/material.dart';

/// Type de message pour personnaliser l'apparence
enum AlertType {
  error,    // Erreur (rouge)
  success,  // Succès (vert)
  warning,  // Avertissement (orange)
  info,     // Information (bleu)
}

/// Popup personnalisé et élégant pour afficher des messages
class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final String? buttonText;
  final VoidCallback? onConfirm;
  final bool showCancelButton;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = AlertType.info,
    this.buttonText,
    this.onConfirm,
    this.showCancelButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForType(type);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône avec cercle coloré
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors['background']!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(type),
                size: 40,
                color: colors['primary'],
              ),
            ),
            const SizedBox(height: 20),
            
            // Titre
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors['primary'],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Boutons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showCancelButton) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors['primary'],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText ?? 'OK',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne les couleurs selon le type
  Map<String, Color> _getColorsForType(AlertType type) {
    switch (type) {
      case AlertType.error:
        return {
          'primary': const Color(0xFFE53935),
          'background': const Color(0xFFE53935),
        };
      case AlertType.success:
        return {
          'primary': const Color(0xFF4CAF50),
          'background': const Color(0xFF4CAF50),
        };
      case AlertType.warning:
        return {
          'primary': const Color(0xFFFF9800),
          'background': const Color(0xFFFF9800),
        };
      case AlertType.info:
        return {
          'primary': const Color(0xFF3EB2FF),
          'background': const Color(0xFF3EB2FF),
        };
    }
  }

  /// Retourne l'icône selon le type
  IconData _getIconForType(AlertType type) {
    switch (type) {
      case AlertType.error:
        return Icons.error_outline_rounded;
      case AlertType.success:
        return Icons.check_circle_outline_rounded;
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.info:
        return Icons.info_outline_rounded;
    }
  }

  /// Affiche le popup
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    AlertType type = AlertType.info,
    String? buttonText,
    VoidCallback? onConfirm,
    bool showCancelButton = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomAlertDialog(
        title: title,
        message: message,
        type: type,
        buttonText: buttonText,
        onConfirm: onConfirm,
        showCancelButton: showCancelButton,
      ),
    );
  }

  /// Helper pour afficher une erreur
  static Future<void> showError({
    required BuildContext context,
    required String message,
    String title = 'Erreur',
    String? buttonText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: AlertType.error,
      buttonText: buttonText,
      onConfirm: onConfirm,
    );
  }

  /// Helper pour afficher un succès
  static Future<void> showSuccess({
    required BuildContext context,
    required String message,
    String title = 'Succès',
    String? buttonText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: AlertType.success,
      buttonText: buttonText,
      onConfirm: onConfirm,
    );
  }

  /// Helper pour afficher un avertissement
  static Future<void> showWarning({
    required BuildContext context,
    required String message,
    String title = 'Attention',
    String? buttonText,
    VoidCallback? onConfirm,
    bool showCancelButton = false,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: AlertType.warning,
      buttonText: buttonText,
      onConfirm: onConfirm,
      showCancelButton: showCancelButton,
    );
  }

  /// Helper pour afficher une information
  static Future<void> showInfo({
    required BuildContext context,
    required String message,
    String title = 'Information',
    String? buttonText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: AlertType.info,
      buttonText: buttonText,
      onConfirm: onConfirm,
    );
  }
}


