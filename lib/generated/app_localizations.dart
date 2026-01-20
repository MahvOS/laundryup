import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Laundry App'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email / Phone Number'**
  String get emailOrPhone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Customer Dashboard'**
  String get dashboard;

  /// No description provided for @bookingLaundry.
  ///
  /// In en, this message translates to:
  /// **'Book Laundry'**
  String get bookingLaundry;

  /// No description provided for @statusLaundry.
  ///
  /// In en, this message translates to:
  /// **'Laundry Status'**
  String get statusLaundry;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @digitalPayment.
  ///
  /// In en, this message translates to:
  /// **'Digital Payment'**
  String get digitalPayment;

  /// No description provided for @promoBanner.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our Integrated Laundry System!'**
  String get promoBanner;

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select Service Type:'**
  String get selectService;

  /// No description provided for @dryWash.
  ///
  /// In en, this message translates to:
  /// **'Dry Wash'**
  String get dryWash;

  /// No description provided for @washIron.
  ///
  /// In en, this message translates to:
  /// **'Wash & Iron'**
  String get washIron;

  /// No description provided for @express.
  ///
  /// In en, this message translates to:
  /// **'Express'**
  String get express;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pickDate;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick Time'**
  String get pickTime;

  /// No description provided for @deliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery Type:'**
  String get deliveryType;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @selfDrop.
  ///
  /// In en, this message translates to:
  /// **'Self Drop-off'**
  String get selfDrop;

  /// No description provided for @estimatedWeight.
  ///
  /// In en, this message translates to:
  /// **'Estimated Weight (kg):'**
  String get estimatedWeight;

  /// No description provided for @expressService.
  ///
  /// In en, this message translates to:
  /// **'Express Service (24 hours):'**
  String get expressService;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get estimatedTotal;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @qris.
  ///
  /// In en, this message translates to:
  /// **'QRIS'**
  String get qris;

  /// No description provided for @dana.
  ///
  /// In en, this message translates to:
  /// **'Dana'**
  String get dana;

  /// No description provided for @ovo.
  ///
  /// In en, this message translates to:
  /// **'OVO'**
  String get ovo;

  /// No description provided for @shopeePay.
  ///
  /// In en, this message translates to:
  /// **'ShopeePay'**
  String get shopeePay;

  /// No description provided for @invoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Invoice will be sent automatically after payment.'**
  String get invoiceNote;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bookingHistory.
  ///
  /// In en, this message translates to:
  /// **'Booking History:'**
  String get bookingHistory;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get date;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status:'**
  String get status;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes:'**
  String get notes;

  /// No description provided for @confirmDeleteBooking.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this booking?'**
  String get confirmDeleteBooking;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @completeBookingData.
  ///
  /// In en, this message translates to:
  /// **'Complete booking data and ensure weight > 0'**
  String get completeBookingData;

  /// No description provided for @bookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking successful'**
  String get bookingSuccess;

  /// No description provided for @selectServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Select service'**
  String get selectServiceHint;

  /// No description provided for @enterWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Enter weight in kg'**
  String get enterWeightHint;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @chooseBookingToPay.
  ///
  /// In en, this message translates to:
  /// **'Choose Order to Pay'**
  String get chooseBookingToPay;

  /// No description provided for @paymentMethodText.
  ///
  /// In en, this message translates to:
  /// **'Please choose the payment method that is most convenient for you.'**
  String get paymentMethodText;

  /// No description provided for @scanQris.
  ///
  /// In en, this message translates to:
  /// **'Scan QRIS'**
  String get scanQris;

  /// No description provided for @scanQrisDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code above using your preferred Bank or E-Wallet app.'**
  String get scanQrisDesc;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get needHelp;

  /// No description provided for @helpDesc.
  ///
  /// In en, this message translates to:
  /// **'Click the button below to confirm payment or ask for account details via WhatsApp.'**
  String get helpDesc;

  /// No description provided for @contactWa.
  ///
  /// In en, this message translates to:
  /// **'Contact via WhatsApp'**
  String get contactWa;

  /// No description provided for @invoiceAutoNote.
  ///
  /// In en, this message translates to:
  /// **'Invoice will be sent automatically after your payment is confirmed by the admin.'**
  String get invoiceAutoNote;

  /// No description provided for @laundryProgress.
  ///
  /// In en, this message translates to:
  /// **'Laundry Progress'**
  String get laundryProgress;

  /// No description provided for @fullHistory.
  ///
  /// In en, this message translates to:
  /// **'Full History'**
  String get fullHistory;

  /// No description provided for @updatedBy.
  ///
  /// In en, this message translates to:
  /// **'Updated by'**
  String get updatedBy;

  /// No description provided for @doneAt.
  ///
  /// In en, this message translates to:
  /// **'Completed at'**
  String get doneAt;

  /// No description provided for @totalFees.
  ///
  /// In en, this message translates to:
  /// **'Total Fees'**
  String get totalFees;

  /// No description provided for @payNowWa.
  ///
  /// In en, this message translates to:
  /// **'Pay Now (WA)'**
  String get payNowWa;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get orderNumber;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @noOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'No order history yet'**
  String get noOrderHistory;

  /// No description provided for @orderIn.
  ///
  /// In en, this message translates to:
  /// **'Incoming Orders'**
  String get orderIn;

  /// No description provided for @addNewOrder.
  ///
  /// In en, this message translates to:
  /// **'Add New Order'**
  String get addNewOrder;

  /// No description provided for @manualOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter customer order details manually'**
  String get manualOrderDesc;

  /// No description provided for @customerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInfo;

  /// No description provided for @serviceDetails.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// No description provided for @timeAndDelivery.
  ///
  /// In en, this message translates to:
  /// **'Time & Delivery'**
  String get timeAndDelivery;

  /// No description provided for @saveCreateOrder.
  ///
  /// In en, this message translates to:
  /// **'Save & Create Order'**
  String get saveCreateOrder;

  /// No description provided for @deleteBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Booking?'**
  String get deleteBookingTitle;

  /// No description provided for @deleteBookingConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently delete this booking from the system.'**
  String get deleteBookingConfirm;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @optionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get optionalNotes;

  /// No description provided for @addNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes for customer'**
  String get addNotesHint;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// No description provided for @staffPortal.
  ///
  /// In en, this message translates to:
  /// **'Staff Portal'**
  String get staffPortal;

  /// No description provided for @todaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaySummary;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewOrders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get viewOrders;

  /// No description provided for @pickupSchedule.
  ///
  /// In en, this message translates to:
  /// **'Pickup Schedule'**
  String get pickupSchedule;

  /// No description provided for @latestBooking.
  ///
  /// In en, this message translates to:
  /// **'Latest Bookings'**
  String get latestBooking;

  /// No description provided for @contactCustomer.
  ///
  /// In en, this message translates to:
  /// **'Contact Customer'**
  String get contactCustomer;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No bookings at the moment'**
  String get noOrders;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @signInDesc.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue'**
  String get signInDesc;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @orderDetail.
  ///
  /// In en, this message translates to:
  /// **'Order Detail'**
  String get orderDetail;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress...'**
  String get inProgress;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @waError.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get waError;

  /// No description provided for @waMeMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello, I would like to make a payment for my laundry booking.'**
  String get waMeMessage;

  /// No description provided for @waMeMessageStatus.
  ///
  /// In en, this message translates to:
  /// **'Hello, I would like to pay for order #{id} ({service}) with a total price of Rp {price}. Please provide further instructions.'**
  String waMeMessageStatus(Object id, Object price, Object service);

  /// No description provided for @bookingIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Booking ID not found. Please create a booking first.'**
  String get bookingIdNotFound;

  /// No description provided for @loadStatusFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to load status data'**
  String get loadStatusFail;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @readyToPickup.
  ///
  /// In en, this message translates to:
  /// **'Ready to Pickup'**
  String get readyToPickup;

  /// No description provided for @readyToDeliver.
  ///
  /// In en, this message translates to:
  /// **'Ready to Deliver'**
  String get readyToDeliver;

  /// No description provided for @laundry.
  ///
  /// In en, this message translates to:
  /// **'Laundry'**
  String get laundry;

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on'**
  String get completedOn;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProcess.
  ///
  /// In en, this message translates to:
  /// **'In process...'**
  String get inProcess;

  /// No description provided for @selectOperationTime.
  ///
  /// In en, this message translates to:
  /// **'Select Operation Time (Scroll down)'**
  String get selectOperationTime;

  /// No description provided for @operationHours.
  ///
  /// In en, this message translates to:
  /// **'Laundry operation hours'**
  String get operationHours;

  /// No description provided for @greetLogin.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Please login to your account.'**
  String get greetLogin;

  /// No description provided for @greetRegister.
  ///
  /// In en, this message translates to:
  /// **'Create a new account to start using our services.'**
  String get greetRegister;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Number'**
  String get whatsappNumber;

  /// No description provided for @whatsappRequired.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number is required'**
  String get whatsappRequired;

  /// No description provided for @newOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newOrderLabel;

  /// No description provided for @process.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get process;

  /// No description provided for @deletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccess;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @weighed.
  ///
  /// In en, this message translates to:
  /// **'Weighed'**
  String get weighed;

  /// No description provided for @washed.
  ///
  /// In en, this message translates to:
  /// **'Washed'**
  String get washed;

  /// No description provided for @dried.
  ///
  /// In en, this message translates to:
  /// **'Dried'**
  String get dried;

  /// No description provided for @ironed.
  ///
  /// In en, this message translates to:
  /// **'Ironed'**
  String get ironed;

  /// No description provided for @contactCustomerMsg.
  ///
  /// In en, this message translates to:
  /// **'Hello {customer}, we would like to confirm the {delivery} schedule for your LaundryUp order.'**
  String contactCustomerMsg(Object customer, Object delivery);

  /// No description provided for @customerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone / WhatsApp Number'**
  String get customerPhoneLabel;

  /// No description provided for @customerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 08123xxx'**
  String get customerPhoneHint;

  /// No description provided for @customerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get customerNameLabel;

  /// No description provided for @customerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter customer name'**
  String get customerNameHint;

  /// No description provided for @express24.
  ///
  /// In en, this message translates to:
  /// **'Express 24 Hours'**
  String get express24;

  /// No description provided for @completeData.
  ///
  /// In en, this message translates to:
  /// **'Complete data'**
  String get completeData;

  /// No description provided for @successAddOrder.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully'**
  String get successAddOrder;

  /// No description provided for @failLoadBookings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load bookings'**
  String get failLoadBookings;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
