import 'package:sendgrid_mailer/sendgrid_mailer.dart';

class EmailService {
  final Mailer _mailer;

  EmailService(String apiKey) : _mailer = Mailer(apiKey);

  Future<void> sendApprovalNotification({
    required String email,
    required String userName,
    required bool isApproved,
    String? rejectionReason,
  }) async {
    final from = Address('no-reply@craftsmanapp.com', 'Craftsman App');
    final to = Address(email, userName);
    final subject = isApproved 
        ? 'Your Craftsman App Account Has Been Approved'
        : 'Your Craftsman App Account Approval Status';

    final htmlContent = isApproved
        ? _buildApprovalEmail(userName)
        : _buildRejectionEmail(userName, rejectionReason ?? 'Not specified');

    final personalization = Personalization([to]);
    final emailContent = Content('text/html', htmlContent);

    final email = Email(
      [personalization],
      from,
      subject,
      content: [emailContent],
    );

    try {
      await _mailer.send(email);
    } catch (e) {
      throw Exception('Failed to send approval email: $e');
    }
  }

  String _buildApprovalEmail(String userName) {
    return '''
    <html>
      <body>
        <h2>Account Approved</h2>
        <p>Hello $userName,</p>
        <p>Your Craftsman App account has been approved!</p>
        <p>You can now log in and access all features of the app.</p>
        <p>Thank you for joining our community!</p>
      </body>
    </html>
    ''';
  }

  String _buildRejectionEmail(String userName, String reason) {
    return '''
    <html>
      <body>
        <h2>Account Approval Update</h2>
        <p>Hello $userName,</p>
        <p>We regret to inform you that your account approval request has been declined.</p>
        <p><strong>Reason:</strong> $reason</p>
        <p>If you believe this was a mistake, please contact our support team.</p>
      </body>
    </html>
    ''';
  }
}