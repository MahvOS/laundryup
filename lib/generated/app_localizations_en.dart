// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Laundry App';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get emailOrPhone => 'Email / Phone Number';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dashboard => 'Customer Dashboard';

  @override
  String get bookingLaundry => 'Book Laundry';

  @override
  String get statusLaundry => 'Laundry Status';

  @override
  String get transactionHistory => 'Transaction History';

  @override
  String get digitalPayment => 'Digital Payment';

  @override
  String get promoBanner => 'Welcome to our Integrated Laundry System!';

  @override
  String get selectService => 'Select Service Type:';

  @override
  String get dryWash => 'Dry Wash';

  @override
  String get washIron => 'Wash & Iron';

  @override
  String get express => 'Express';

  @override
  String get pickDate => 'Pick Date';

  @override
  String get pickTime => 'Pick Time';

  @override
  String get deliveryType => 'Delivery Type:';

  @override
  String get pickup => 'Pickup';

  @override
  String get selfDrop => 'Self Drop-off';

  @override
  String get estimatedWeight => 'Estimated Weight (kg):';

  @override
  String get expressService => 'Express Service (24 hours):';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get estimatedTotal => 'Estimated Total';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get qris => 'QRIS';

  @override
  String get dana => 'Dana';

  @override
  String get ovo => 'OVO';

  @override
  String get shopeePay => 'ShopeePay';

  @override
  String get invoiceNote => 'Invoice will be sent automatically after payment.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Logout';

  @override
  String get delete => 'Delete';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get english => 'English';

  @override
  String get bookingHistory => 'Booking History:';

  @override
  String get date => 'Date:';

  @override
  String get status => 'Status:';

  @override
  String get notes => 'Notes:';

  @override
  String get confirmDeleteBooking =>
      'Are you sure you want to delete this booking?';

  @override
  String get cancel => 'Cancel';

  @override
  String get completeBookingData =>
      'Complete booking data and ensure weight > 0';

  @override
  String get bookingSuccess => 'Booking successful';

  @override
  String get selectServiceHint => 'Select service';

  @override
  String get enterWeightHint => 'Enter weight in kg';

  @override
  String get required => 'Required';

  @override
  String get name => 'Name';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get chooseBookingToPay => 'Choose Order to Pay';

  @override
  String get paymentMethodText =>
      'Please choose the payment method that is most convenient for you.';

  @override
  String get scanQris => 'Scan QRIS';

  @override
  String get scanQrisDesc =>
      'Scan the QR code above using your preferred Bank or E-Wallet app.';

  @override
  String get or => 'Or';

  @override
  String get needHelp => 'Need Help?';

  @override
  String get helpDesc =>
      'Click the button below to confirm payment or ask for account details via WhatsApp.';

  @override
  String get contactWa => 'Contact via WhatsApp';

  @override
  String get invoiceAutoNote =>
      'Invoice will be sent automatically after your payment is confirmed by the admin.';

  @override
  String get laundryProgress => 'Laundry Progress';

  @override
  String get fullHistory => 'Full History';

  @override
  String get updatedBy => 'Updated by';

  @override
  String get doneAt => 'Completed at';

  @override
  String get totalFees => 'Total Fees';

  @override
  String get payNowWa => 'Pay Now (WA)';

  @override
  String get orderNumber => 'Order #';

  @override
  String get hello => 'Hello';

  @override
  String get seeAll => 'See All';

  @override
  String get noOrderHistory => 'No order history yet';

  @override
  String get orderIn => 'Incoming Orders';

  @override
  String get addNewOrder => 'Add New Order';

  @override
  String get manualOrderDesc => 'Enter customer order details manually';

  @override
  String get customerInfo => 'Customer Information';

  @override
  String get serviceDetails => 'Service Details';

  @override
  String get timeAndDelivery => 'Time & Delivery';

  @override
  String get saveCreateOrder => 'Save & Create Order';

  @override
  String get deleteBookingTitle => 'Delete Booking?';

  @override
  String get deleteBookingConfirm =>
      'This action will permanently delete this booking from the system.';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get optionalNotes => 'Notes (optional)';

  @override
  String get addNotesHint => 'Add notes for customer';

  @override
  String get refreshData => 'Refresh Data';

  @override
  String get staffPortal => 'Staff Portal';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get viewOrders => 'View Orders';

  @override
  String get pickupSchedule => 'Pickup Schedule';

  @override
  String get latestBooking => 'Latest Bookings';

  @override
  String get contactCustomer => 'Contact Customer';

  @override
  String get noOrders => 'No bookings at the moment';

  @override
  String get welcome => 'Welcome';

  @override
  String get signInDesc => 'Please sign in to continue';

  @override
  String get signUp => 'Sign Up';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get user => 'User';

  @override
  String get orderDetail => 'Order Detail';

  @override
  String get inProgress => 'In progress...';

  @override
  String get done => 'Done';

  @override
  String get waError => 'Could not open WhatsApp';

  @override
  String get waMeMessage =>
      'Hello, I would like to make a payment for my laundry booking.';

  @override
  String waMeMessageStatus(Object id, Object price, Object service) {
    return 'Hello, I would like to pay for order #$id ($service) with a total price of Rp $price. Please provide further instructions.';
  }

  @override
  String get bookingIdNotFound =>
      'Booking ID not found. Please create a booking first.';

  @override
  String get loadStatusFail => 'Failed to load status data';

  @override
  String get alert => 'Alert';

  @override
  String get readyToPickup => 'Ready to Pickup';

  @override
  String get readyToDeliver => 'Ready to Deliver';

  @override
  String get laundry => 'Laundry';

  @override
  String get completedOn => 'Completed on';

  @override
  String get completed => 'Completed';

  @override
  String get inProcess => 'In process...';

  @override
  String get selectOperationTime => 'Select Operation Time (Scroll down)';

  @override
  String get operationHours => 'Laundry operation hours';

  @override
  String get greetLogin => 'Welcome back! Please login to your account.';

  @override
  String get greetRegister =>
      'Create a new account to start using our services.';

  @override
  String get whatsappNumber => 'WhatsApp Number';

  @override
  String get whatsappRequired => 'WhatsApp number is required';

  @override
  String get newOrderLabel => 'New';

  @override
  String get process => 'Process';

  @override
  String get deletedSuccess => 'Deleted successfully';

  @override
  String get received => 'Received';

  @override
  String get weighed => 'Weighed';

  @override
  String get washed => 'Washed';

  @override
  String get dried => 'Dried';

  @override
  String get ironed => 'Ironed';

  @override
  String contactCustomerMsg(Object customer, Object delivery) {
    return 'Hello $customer, we would like to confirm the $delivery schedule for your LaundryUp order.';
  }

  @override
  String get customerPhoneLabel => 'Phone / WhatsApp Number';

  @override
  String get customerPhoneHint => 'Example: 08123xxx';

  @override
  String get customerNameLabel => 'Nickname';

  @override
  String get customerNameHint => 'Enter customer name';

  @override
  String get express24 => 'Express 24 Hours';

  @override
  String get completeData => 'Complete data';

  @override
  String get successAddOrder => 'Order created successfully';

  @override
  String get failLoadBookings => 'Failed to load bookings';

  @override
  String get update => 'Update';
}
