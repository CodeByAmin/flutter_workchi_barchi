import '../constants.dart';

class ValidationUtils {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'لطفا شماره موبایل را وارد کنید';
    }
    
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (!ValidationRegex.iranianPhone.hasMatch(cleanPhone)) {
      return 'شماره موبایل معتبر نیست';
    }
    
    return null;
  }
  
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'لطفا کد تایید را وارد کنید';
    }
    
    if (value.length != AppConstants.otpLength) {
      return 'کد تایید باید ۶ رقم باشد';
    }
    
    if (!ValidationRegex.otpCode.hasMatch(value)) {
      return 'کد تایید باید فقط شامل اعداد باشد';
    }
    
    return null;
  }
  
  static String formatPhoneNumber(String phone) {
    String formatted = phone;
    
    // Remove all non-digits
    formatted = formatted.replaceAll(RegExp(r'[^\d]'), '');
    
    // If starts with 0, replace with +98
    if (formatted.startsWith('0')) {
      formatted = '+98${formatted.substring(1)}';
    }
    // If starts with 9 (Iranian mobile without country code)
    else if (formatted.startsWith('9') && formatted.length == 10) {
      formatted = '+98$formatted';
    }
    // If already has +98
    else if (formatted.startsWith('98')) {
      formatted = '+$formatted';
    }
    
    return formatted;
  }
  
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} سال پیش';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ماه پیش';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} هفته پیش';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} روز پیش';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعت پیش';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقیقه پیش';
    } else {
      return 'همین حالا';
    }
  }
}