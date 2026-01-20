import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:LaundryUp/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:LaundryUp/generated/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<dynamic> _bookings = [];
  dynamic _selectedBooking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await ApiService.getUserBookings();
      setState(() {
        _bookings = bookings.where((b) => b['current_status'] != 'Selesai').toList();
        if (_bookings.isNotEmpty) {
          _selectedBooking = _bookings.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.paymentTitle)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet_rounded, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 32),
            
            if (_bookings.isNotEmpty) ...[
              Text(
                l10n.chooseBookingToPay,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<dynamic>(
                    value: _selectedBooking,
                    isExpanded: true,
                    items: _bookings.map((booking) {
                      final price = NumberFormat('#,###', 'id_ID').format(double.tryParse(booking['estimated_total']?.toString() ?? '0') ?? 0);
                      return DropdownMenuItem<dynamic>(
                        value: booking,
                        child: Text('${l10n.orderNumber}${booking['id']} - Rp $price'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBooking = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            Text(
              l10n.paymentMethod,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.paymentMethodText,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // QRIS Section
            Card(
              elevation: 4,
              shadowColor: theme.colorScheme.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.scanQris,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/QRIS.png',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.scanQrisDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Text(l10n.or, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      l10n.needHelp,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.helpDesc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          const phone = '6281282480007';
                          String message = l10n.waMeMessage;
                          
                          if (_selectedBooking != null) {
                            final price = NumberFormat('#,###', 'id_ID').format(double.tryParse(_selectedBooking['estimated_total']?.toString() ?? '0') ?? 0);
                            message = l10n.waMeMessageStatus(
                                _selectedBooking['id'].toString(),
                                _selectedBooking['service_name'],
                                price,
                            );
                          }

                          final waUrl = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
                          try {
                            if (!await launchUrl(waUrl, mode: LaunchMode.externalApplication)) {
                              throw 'Could not launch $waUrl';
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${l10n.waError}: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.chat_bubble_rounded),
                        label: Text(l10n.contactWa),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.invoiceAutoNote,
                      style: const TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
