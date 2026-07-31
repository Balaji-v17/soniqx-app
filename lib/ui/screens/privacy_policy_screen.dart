import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final bgColor = isDarkMode ? const Color(0xFF0A0A0A) : Colors.white;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy policy',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // This adds the thin colored line under the AppBar seen in the video
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: primaryColor.withOpacity(0.5),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle('Privacy Policy for Soniq'),
            _buildBody('Last Updated: July 30, 2026\n\nThis Privacy Policy applies to the Soniq mobile application (the "Application") developed by Lambda_17 (the "Developer").', subTextColor),
            
            _buildSectionHeader('1. Data Collection and Use'),
            _buildBody('Soniq is an offline music player that operates primarily on your device. The Application does not collect, transmit, store, or share any Personally Identifiable Information (PII), location data, or usage analytics with the Developer or any third-party servers.', subTextColor),
            
            _buildSectionHeader('2. Storage Permissions and Media Access'),
            _buildBody('To function as an offline music player, the Application requires access to audio files stored on your device.\n\n• Audio Files: The Application requests permission to read audio files (such as MP3 files) stored on your device solely for audio playback, library management, and related music player functionality.\n• File Deletion (MANAGE_EXTERNAL_STORAGE): On devices running Android 11 or higher, the Application requests the MANAGE_EXTERNAL_STORAGE (All Files Access) permission. This permission is used exclusively for the core functionality of permanently deleting audio files or moving them to the system Recycle Bin/Trash, based solely on actions explicitly initiated by the user.\n\nThe Application accesses only the files and directories necessary for media playback and user-requested file management operations. No audio files or metadata are ever uploaded to external servers or shared with third parties.', subTextColor),
            
            _buildSectionHeader('3. Third-Party Services'),
            _buildBody('The Application does not integrate any third-party analytics, advertising networks, or crash-reporting SDKs that transmit data over the internet. The Application uses on-device machine learning to classify the language of audio files based on locally available metadata. All processing occurs entirely offline on the user\'s device.', subTextColor),
            
            _buildSectionHeader('4. Data Deletion'),
            _buildBody('Because the Application does not collect user data, accounts, or telemetry, there is no user data stored remotely to delete. Uninstalling the Application removes its locally stored application data from your device, subject to your device\'s operating system behavior.', subTextColor),
            
            _buildSectionHeader('5. Changes to This Privacy Policy'),
            _buildBody('The Developer may update this Privacy Policy from time to time. Any updates to this Privacy Policy will be reflected by revising the "Last Updated" date at the top of this page.', subTextColor),
            
            _buildSectionHeader('6. Contact Us'),
            _buildBody('If you have any questions about this Privacy Policy, you may contact the Developer at: balaji2005.su@gmail.com.', subTextColor),
            
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBody(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 15, height: 1.5, color: color),
    );
  }
}