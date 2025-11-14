import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Developer Info
  final String developerName = "Peash Das Rudra";
  final String developerEmail = "loom.support@gmail.com";

  // Socials
  final String github = "https://github.com/peashdasrudra";
  final String instagram = "https://instagram.com/rudraa.io";
  final String linkedin = "https://linkedin.com/in/peashrudra";
  final String youtube = "https://youtube.com/@peash_rudra";
  final String website = "https://bitly.cx/peashdasrudra";

  // Open URL
  Future<void> openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {}
  }

  // Open email
  Future<void> sendEmail(String email) async {
    final uri = Uri.parse("mailto:$email");
    if (!await launchUrl(uri)) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          "About",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primary,
            fontSize: 22,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: "about_icon",
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.18),
                      primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage("assets/images/me.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // App description (enhanced, modern, eye-catching)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: theme.colorScheme.onBackground.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        size: 32,
                        color: theme.colorScheme.primary.withOpacity(0.85),
                      ),
                      Icon(
                        Icons.stars_rounded,
                        size: 32,
                        color: theme.colorScheme.primary.withOpacity(0.85),
                      ),
                      Icon(
                        Icons.stars_rounded,
                        size: 32,
                        color: theme.colorScheme.primary.withOpacity(0.85),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Share your world, connect with people, and enjoy a smooth and modern social experience.\n"
                    "Thank you for being part of the Loom community!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.onBackground.withOpacity(0.75),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // Developer section title
            Text(
              "Developer",
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            // Developer Name
            Text(
              developerName,
              style: TextStyle(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 8),

            // Email link
            InkWell(
              onTap: () => sendEmail(developerEmail),
              child: Text(
                developerEmail,
                style: TextStyle(
                  color: primary,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 45),

            // Section title
            Text(
              "Connect",
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 18),

            // ICON-ONLY SOCIAL ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialImage(
                  path: "assets/icons/website.png",
                  onTap: () => openLink(website),
                ),
                const SizedBox(width: 20),

                _socialImage(
                  path: "assets/icons/instagram.png",
                  onTap: () => openLink(instagram),
                ),
                const SizedBox(width: 20),

                _socialImage(
                  path: "assets/icons/github.png",
                  onTap: () => openLink(github),
                ),
                const SizedBox(width: 20),

                _socialImage(
                  path: "assets/icons/linkedin.png",
                  onTap: () => openLink(linkedin),
                ),
                const SizedBox(width: 20),

                _socialImage(
                  path: "assets/icons/youtube.png",
                  onTap: () => openLink(youtube),
                ),
              ],
            ),

            const SizedBox(height: 230),

            // footer
            Text(
              "All Rights Reserved By Loom ❤️ ",
              style: TextStyle(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------- SOCIAL ICON BUTTON --------------
  Widget _socialImage({required String path, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.05),
        ),
        child: Image.asset(path, width: 30, height: 30, fit: BoxFit.contain),
      ),
    );
  }
}
