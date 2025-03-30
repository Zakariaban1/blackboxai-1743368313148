class EnvConfig {
  static const String sendGridApiKey = String.fromEnvironment('SENDGRID_API_KEY');
  
  static void validate() {
    if (sendGridApiKey.isEmpty) {
      throw Exception('SENDGRID_API_KEY environment variable is not set');
    }
  }
}