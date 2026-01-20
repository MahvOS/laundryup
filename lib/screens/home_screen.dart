import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:LaundryUp/generated/app_localizations.dart';
import '../services/api_service.dart';
import 'booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBookings();
  }

  Future<void> _loadUserData() async {
    final name = await ApiService.getUserName();
    setState(() {
      _userName = name;
    });
  }

  Future<void> _loadBookings() async {
    try {
      final bookings = await ApiService.getUserBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateString.split('T')[0]; // Fallback
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Diterima':
        return const Color(0xFF3B82F6);
      case 'Ditimbang':
        return const Color(0xFFF59E0B);
      case 'Dicuci':
        return const Color(0xFFF59E0B);
      case 'Dikeringkan':
        return const Color(0xFFF59E0B);
      case 'Disetrika':
        return const Color(0xFFF59E0B);
      case 'Siap Diambil':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Diterima':
        return Icons.check_circle_outline;
      case 'Ditimbang':
        return Icons.scale;
      case 'Dicuci':
        return Icons.local_laundry_service;
      case 'Dikeringkan':
        return Icons.dry_cleaning;
      case 'Disetrika':
        return Icons.iron;
      case 'Siap Diambil':
        return Icons.check_circle;
      default:
        return Icons.schedule;
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadBookings, child: Text(l10n.tryAgain)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("LaundryUp"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              tooltip: l10n.settings,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Greeting & Promo Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.hello}, ${_userName ?? l10n.user} 👋',
                    style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.promoBanner,
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Fast Actions Row
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add_rounded,
                    label: l10n.bookingLaundry,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BookingScreen()),
                      );
                      if (result == true) _loadBookings();
                    },
                    primary: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.account_balance_wallet_outlined,
                    label: l10n.digitalPayment,
                    onPressed: () => Navigator.pushNamed(context, '/payment'),
                    primary: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.bookingHistory, style: theme.textTheme.titleLarge),
                if (_bookings.isNotEmpty)
                  TextButton(
                    onPressed: () {}, // Could be See All
                    child: Text(l10n.seeAll),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_bookings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, size: 64, color: theme.colorScheme.outline.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(l10n.noOrderHistory, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              )
            else
              ..._bookings.map((booking) => _buildBookingCard(booking, l10n, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool primary,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: primary ? theme.colorScheme.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primary ? theme.colorScheme.primary.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: primary ? theme.colorScheme.primary : Colors.blueGrey, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: primary ? theme.colorScheme.primary : Colors.blueGrey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking, dynamic l10n, ThemeData theme) {
    final status = booking['current_status'] ?? 'Unknown';
    return Card(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/status', arguments: booking['id']),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(status), size: 16, color: _getStatusColor(status)),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(booking['booking_date']),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(booking['service_name'], style: theme.textTheme.titleMedium),
              if (booking['notes'] != null && booking['notes'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking['notes'],
                          style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(booking['estimated_total']?.toString() ?? '0') ?? 0)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (booking['notes'] == null || booking['notes'].toString().isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(double.tryParse(booking['estimated_total']?.toString() ?? '0') ?? 0)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.orderDetail, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.colorScheme.outline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
