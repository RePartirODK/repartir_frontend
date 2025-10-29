import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:repartir_frontend/pages/auth/role_selection_page.dart';
import 'package:repartir_frontend/pages/jeuner/accueil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          OnboardingPageContent(
            image: 'assets/images/onboarding1.png',
            title: 'Ton Nouveau Départ',
            description:
                'L\'opportunité que tu attendais est là. Accède à la formation pro et à l\'accompagnement humain.',
            pageController: _pageController,
          ),
          OnboardingPageContent(
            image: 'assets/images/onboarding2.png',
            title: 'Ton Savoir est Ta Force',
            description:
                'Découvre les meilleures formations, financées par ceux qui croient en toi.\n\nChoisis la compétence qui va booster ta carrière et assure ton indépendance.',
            pageController: _pageController,
          ),
          OnboardingPageContent(
            image: 'assets/images/onboarding3.png',
            title: 'Comment ça marche?',
            isLastPage: true,
            pageController: _pageController,
          ),
        ],
      ),
    );
  }
}

class OnboardingPageContent extends StatefulWidget {
  final String image;
  final String title;
  final String? description;
  final bool isLastPage;
  final PageController pageController;

  const OnboardingPageContent({
    super.key,
    required this.image,
    required this.title,
    this.description,
    this.isLastPage = false,
    required this.pageController,
  });

  @override
  State<OnboardingPageContent> createState() => _OnboardingPageContentState();
}

class _OnboardingPageContentState extends State<OnboardingPageContent> {
  bool _isCardVisible = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isCardVisible = !_isCardVisible;
            });
          },
          child: Image.asset(
            widget.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          bottom: _isCardVisible
              ? 0
              : -MediaQuery.of(context).size.height * 0.6,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.50,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (widget.description != null)
                    Text(
                      widget.description!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  if (widget.isLastPage)
                    const Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: [
                          InfoRow(
                            icon: Icons.search,
                            text: 'Trouvez des formations professionnelles',
                          ),
                          SizedBox(height: 15),
                          InfoRow(
                            icon: Icons.people_outline,
                            text: 'Partagez vos experiences',
                          ),
                          SizedBox(height: 15),
                          InfoRow(
                            icon: Icons.volunteer_activism_outlined,
                            text: 'Payez des formations',
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Stack(
                    children: [
                      // Page Indicator - centered horizontally
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: SmoothPageIndicator(
                            controller: widget.pageController,
                            count: 3,
                            onDotClicked: (index) {
                              widget.pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn,
                              );
                            },
                            effect: const WormEffect(
                              spacing: 16,
                              dotColor: Colors.black26,
                              activeDotColor: Colors.blue,
                              dotHeight: 8,
                              dotWidth: 8,
                            ),
                          ),
                        ),
                      ),
                      // Button - bottom right
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10.0,
                            right: 0.0,
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 12,
                              ),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final storage = FlutterSecureStorage();
                              if (widget.isLastPage) {
                  
                              
                                await storage.write(key: 'onboarding_complete',
                                 value: 'true');

                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RoleSelectionPage(),
                                    ),
                                  );
                                }
                              } else {
                                widget.pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn,
                                );
                              }
                            },
                            child: Text(
                              widget.isLastPage ? 'Terminer' : 'Suivant',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const InfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
