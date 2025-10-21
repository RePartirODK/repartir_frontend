import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final Widget? leftWidget;
  final Widget? centerWidget;
  final Widget? rightWidget;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? title;
  final double height;

  const CustomHeader({
    super.key,
    this.leftWidget,
    this.centerWidget,
    this.rightWidget,
    this.showBackButton = false,
    this.onBackPressed,
    this.title,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ProfilePageClipper(),
      child: Container(
        height: height,
        color: const Color(0xFF3EB2FF), // Couleur bleue personnalisée
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Widget de gauche
                    leftWidget ?? 
                    (showBackButton 
                      ? GestureDetector(
                          onTap: onBackPressed ?? () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      : const SizedBox(width: 40)),

                    // Widget du centre
                    centerWidget ??
                    (title != null 
                      ? Text(
                          title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const SizedBox(width: 40)),

                    // Widget de droite
                    rightWidget ?? const SizedBox(width: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CustomClipper pour la forme ondulée de l'en-tête (du profil jeune)
class ProfilePageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
