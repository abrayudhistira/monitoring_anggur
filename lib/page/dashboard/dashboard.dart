import 'package:flutter/material.dart';
import 'package:monitoring_anggur/core/controller/authController.dart';
import 'package:monitoring_anggur/core/controller/settingController.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  // Palet warna ungu anggur
  static const Color grapeDeep = Color(0xFF4A1942);
  static const Color grapePrimary = Color(0xFF6B2D5C);
  static const Color grapeAccent = Color(0xFF8B4789);
  static const Color grapeLight = Color(0xFFB57FB3);
  static const Color grapeSoft = Color(0xFFE8D4E7);

  @override
  Widget build(BuildContext context) {
    // Watch SettingController untuk data real-time suhu, valve, dan mode
    final settingController = context.watch<SettingController>();
    final suhu = settingController.latestSuhu;
    
    // Setting Valve
    final valveSetting = settingController.valveSetting;
    final valveStatus = valveSetting?.status ?? 'UNKNOWN';
    final valveStatusColor = valveStatus == 'ON' 
        ? Colors.green.shade600 
        : (valveStatus == 'OFF' ? Colors.red.shade600 : Colors.grey);
    final toggleValveLabel = valveStatus == 'ON' ? 'Matikan Valve' : 'Nyalakan Valve';
    final newValveStatus = valveStatus == 'ON' ? 'OFF' : 'ON';

    // Setting Mode
    final modeSetting = settingController.modeSetting;
    final modeStatus = modeSetting?.status ?? 'UNKNOWN';
    final isAuto = modeStatus == 'Auto';
    final modeColor = isAuto ? Colors.orange.shade600 : Colors.blue.shade600;
    final modeToggleLabel = isAuto ? 'Ubah ke MANUAL' : 'Ubah ke AUTO';
    final newModeStatus = isAuto ? 'Manual' : 'Auto';
    
    // Read AuthController untuk fungsi logout
    final authController = context.read<AuthController>();

    // Cek apakah tombol Valve harus dinonaktifkan
    final isValveDisabled = isAuto;

    return Scaffold(
      backgroundColor: grapeSoft,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [grapeDeep, grapePrimary, grapeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dashboard_rounded, size: 24, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard IoT',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Monitoring Real-time',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: authController.logout,
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Header Section ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [grapePrimary.withOpacity(0.8), grapeAccent.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: grapePrimary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.spa,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Monitoring Anggur',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // --- Real-time Kelembaban Card ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.water_drop,
                            size: 32,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kelembaban Tanah',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Sensor Real-time',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            suhu != null ? '${suhu.humidity.toStringAsFixed(1)}%' : 'N/A',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: suhu != null ? Colors.green.shade50 : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  suhu != null ? Icons.check_circle : Icons.pending,
                                  size: 16,
                                  color: suhu != null ? Colors.green.shade700 : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  suhu != null 
                                      ? 'Update: ${DateFormat('HH:mm:ss').format(suhu.timestamp)}'
                                      : 'Menunggu data sensor...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: suhu != null ? Colors.green.shade700 : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Mode Kontrol Section ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings_suggest_rounded,
                          color: grapeAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mode Kontrol',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: grapeDeep,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            modeColor.withOpacity(0.1),
                            modeColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: modeColor, width: 2),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isAuto ? Icons.smart_toy_rounded : Icons.pan_tool_alt_rounded,
                            size: 48,
                            color: modeColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Mode: $modeStatus',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: modeColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAuto 
                                ? 'Sistem mengontrol valve secara otomatis'
                                : 'Anda mengontrol valve secara manual',
                            style: TextStyle(
                              fontSize: 13,
                              color: modeColor.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => settingController.updateModeStatus(newModeStatus),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: modeColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isAuto ? Icons.pan_tool_alt_rounded : Icons.smart_toy_rounded,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              modeToggleLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Kontrol Valve Section ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_rounded,
                          color: grapeAccent,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status Valve',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: grapeDeep,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status Circle
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            valveStatusColor.withOpacity(0.3),
                            valveStatusColor.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: valveStatusColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              valveStatus == 'ON' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              size: 48,
                              color: valveStatusColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              valveStatus,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: valveStatusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info jika mode auto
                    if (isValveDisabled)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_rounded,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Valve dikontrol otomatis. Ubah ke mode Manual untuk kontrol manual.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Toggle Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isValveDisabled ? null : () {
                          settingController.updateValveStatus(newValveStatus);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isValveDisabled ? Colors.grey : valveStatusColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          elevation: isValveDisabled ? 0 : 3,
                          shadowColor: valveStatusColor.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              valveStatus == 'ON' 
                                  ? Icons.power_settings_new_rounded 
                                  : Icons.power_rounded,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              toggleValveLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Last Update Info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: grapeSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: grapeAccent,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            valveSetting != null 
                                ? 'Update: ${DateFormat('dd MMM yyyy, HH:mm:ss').format(valveSetting.updatedAt ?? DateTime.now())}'
                                : 'Loading Setting...',
                            style: TextStyle(
                              fontSize: 12,
                              color: grapeDeep,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Footer Info
            Center(
              child: Text(
                '© 2025 Capstone Anggur. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: grapeAccent.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}