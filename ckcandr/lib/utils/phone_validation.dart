/// Vietnamese phone number validation utilities
/// 
/// This file contains utilities for validating Vietnamese phone numbers

/// Vietnamese phone number validation function
/// Supports formats:
/// - 0xxxxxxxxx (10 digits starting with 0)
/// - +84xxxxxxxxx (with country code)
/// - 84xxxxxxxxx (without + sign)
/// Valid prefixes: 03, 05, 07, 08, 09
bool isVietnamesePhoneNumberValid(String number) {
  return RegExp(r'^(((\+|)84)|0)(3|5|7|8|9)+([0-9]{8})\b$').hasMatch(number);
}

/// Test cases for Vietnamese phone number validation
void testVietnamesePhoneValidation() {
  // Valid numbers
  assert(isVietnamesePhoneNumberValid('0123456789') == true);
  assert(isVietnamesePhoneNumberValid('0987654321') == true);
  assert(isVietnamesePhoneNumberValid('+84123456789') == true);
  assert(isVietnamesePhoneNumberValid('84123456789') == true);
  assert(isVietnamesePhoneNumberValid('0356789012') == true);
  assert(isVietnamesePhoneNumberValid('0789012345') == true);
  assert(isVietnamesePhoneNumberValid('0812345678') == true);
  assert(isVietnamesePhoneNumberValid('0901234567') == true);
  
  // Invalid numbers
  assert(isVietnamesePhoneNumberValid('0123456') == false); // Too short
  assert(isVietnamesePhoneNumberValid('01234567890') == false); // Too long
  assert(isVietnamesePhoneNumberValid('0223456789') == false); // Invalid prefix 02
  assert(isVietnamesePhoneNumberValid('0423456789') == false); // Invalid prefix 04
  assert(isVietnamesePhoneNumberValid('0623456789') == false); // Invalid prefix 06
  assert(isVietnamesePhoneNumberValid('1123456789') == false); // Invalid start
  assert(isVietnamesePhoneNumberValid('abc1234567') == false); // Contains letters
  assert(isVietnamesePhoneNumberValid('') == false); // Empty
  
  print('All Vietnamese phone validation tests passed!');
}
