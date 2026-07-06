import 'package:flutter/material.dart';
import 'package:dispenxcore_frontend/core/di/injector.dart';
import 'package:dispenxcore_frontend/features/dispenser/domain/usecases/activate_dispenser.dart';

// debe coincidir con el DEVICE_ID del ESP32
const String _kDeviceId = 'esp32_01';

class DispenserHomePage extends StatefulWidget {
  const DispenserHomePage({super.key});

  @override
  State<DispenserHomePage> createState() => _DispenserHomePageState();
}

class _DispenserHomePageState extends State<DispenserHomePage> {
  bool _cargando = false;
  String? _mensaje;
  bool? _exito;

  Future<void> _dispensar() async {
    setState(() {
      _cargando = true;
      _mensaje = null;
      _exito = null;
    });
    try {
      final useCase = injector<ActivateDispenser>();
      final result = await useCase(deviceId: _kDeviceId, supplyType: 'Arroz');
      if (!mounted) return;
      setState(() {
        _exito = result.success;
        _mensaje = result.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _exito = false;
        _mensaje = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.set_meal_rounded,
                size: 56,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(height: 16),
              const Text(
                'DispenXCore',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dispensador automático de granos',
                style: TextStyle(
                  fontFamily: 'Arimo',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _dispensar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    disabledBackgroundColor: const Color(0xFF93C5FD),
                    shape: const CircleBorder(),
                    elevation: 6,
                    shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
                  ),
                  child: _cargando
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'DISPENSAR',
                              style: TextStyle(
                                fontFamily: 'Arimo',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              if (_mensaje != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: _exito == true
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _exito == true
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _exito == true
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color: _exito == true
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _mensaje!,
                          style: TextStyle(
                            fontFamily: 'Arimo',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _exito == true
                                ? const Color(0xFF15803D)
                                : const Color(0xFFB91C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
