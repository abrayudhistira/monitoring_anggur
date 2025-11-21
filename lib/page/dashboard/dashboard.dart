import 'package:flutter/material.dart';
import 'package:monitoring_anggur/core/controller/authController.dart';
import 'package:monitoring_anggur/core/controller/settingController.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch SettingController untuk data real-time suhu, valve, dan mode
    final settingController = context.watch<SettingController>();
    final suhu = settingController.latestSuhu;
    
    // Setting Valve
    final valveSetting = settingController.valveSetting;
    final valveStatus = valveSetting?.status ?? 'UNKNOWN';
    final valveStatusColor = valveStatus == 'ON' ? Colors.green : (valveStatus == 'OFF' ? Colors.red : Colors.grey);
    final toggleValveLabel = valveStatus == 'ON' ? 'Matikan Valve' : 'Nyalakan Valve';
    final newValveStatus = valveStatus == 'ON' ? 'OFF' : 'ON';

    // Setting Mode
    final modeSetting = settingController.modeSetting;
    final modeStatus = modeSetting?.status ?? 'UNKNOWN';
    final isAuto = modeStatus == 'Auto';
    final modeColor = isAuto ? Colors.orange : Colors.blue;
    final modeToggleLabel = isAuto ? 'Ubah ke MANUAL' : 'Ubah ke AUTO';
    final newModeStatus = isAuto ? 'Manual' : 'Auto';
    
    // Read AuthController untuk fungsi logout
    final authController = context.read<AuthController>();

    // Cek apakah tombol Valve harus dinonaktifkan
    final isValveDisabled = isAuto;


    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Real-time Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // --- Real-time Suhu (Humidity) ---
              Card(
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.cloud, size: 40, color: Colors.blue),
                  title: const Text('Kelembaban Saat Ini', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: suhu == null
                      ? const Text('Menunggu data sensor...')
                      : Text('Last Update: ${DateFormat('HH:mm:ss').format(suhu.timestamp)}'),
                  trailing: Text(
                    suhu != null ? '${suhu.humidity.toStringAsFixed(2)} %' : 'N/A',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- Mode Kontrol Otomatis/Manual ---
              Text('Mode Kontrol', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: modeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: modeColor),
                ),
                child: Column(
                  children: [
                    Text(
                      'Mode: $modeStatus',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: modeColor),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () => settingController.updateModeStatus(newModeStatus),
                      icon: Icon(isAuto ? Icons.settings : Icons.pan_tool_alt, color: Colors.white),
                      label: Text(modeToggleLabel, style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: modeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              
              // --- Kontrol Valve Utama ---
              Text('Status Valve', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              
              CircleAvatar(
                radius: 50,
                backgroundColor: valveStatusColor.withOpacity(0.2),
                child: Text(
                  valveStatus,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valveStatusColor),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // --- Tombol Kontrol Valve ---
              Tooltip(
                message: isValveDisabled ? 'Valve dikontrol Otomatis, ubah mode ke Manual untuk mengontrol.' : toggleValveLabel,
                child: ElevatedButton.icon(
                  onPressed: isValveDisabled ? null : () {
                    // Panggil PUT API untuk mengubah status Valve
                    settingController.updateValveStatus(newValveStatus);
                  },
                  icon: Icon(valveStatus == 'ON' ? Icons.power_settings_new : Icons.power_off, color: Colors.white),
                  label: Text(toggleValveLabel, style: const TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValveDisabled ? Colors.grey : valveStatusColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              Text(
                valveSetting != null 
                    ? 'Terakhir diperbarui: ${DateFormat('dd MMM yyyy HH:mm:ss').format(valveSetting.updatedAt ?? DateTime.now())}'
                    : 'Loading Setting...',
                style: const TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}