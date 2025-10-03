class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000/api';
  static const String aiServiceUrl = 'http://localhost:8000';
  
  // App Information
  static const String appName = 'SmartDinner';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Time Constants
  static const int requestTimeoutSeconds = 30;
  static const int connectionTimeoutSeconds = 10;
  
  // Restaurant Configuration
  static const int maxGuestsPerReservation = 12;
  static const int minGuestsPerReservation = 1;
  static const int reservationTimeSlotMinutes = 30;
  
  // Order Configuration
  static const double minOrderAmount = 5.0;
  static const double deliveryFee = 2.50;
  static const int estimatedDeliveryMinutes = 30;
}
