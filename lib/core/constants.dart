// lib/core/constants.dart

// CONFIGURACION DE BASE_URL
// ============================================
// Descomenta la línea que corresponda a tu entorno:

// 1. BACKEND DEPLOYADO (Producción/Staging)
const String BASE_URL = 'https://dispenxcore-backend-production.up.railway.app';
// 2. EDGE SERVICE (Flask local — ESP32 via polling)
// IP del Mac en la red local. Obtener con: ipconfig getifaddr en0
// El dispositivo y el celular deben estar en la misma red WiFi 2.4GHz que el ESP32.
const String EDGE_BASE_URL = 'http://192.168.18.22:5000';

// 3. EMULADOR ANDROID (Desarrollo local)
// const String BASE_URL = 'http://10.0.2.2:5000/api/v1';

// 4. DISPOSITIVO FÍSICO EN RED LOCAL (Desarrollo)
// const String BASE_URL = 'http://TU_IP_LOCAL:5000/api/v1';
// Para obtener tu IP local en Windows: ipconfig en CMD
// Ejemplo: const String BASE_URL = 'http://192.168.1.10:5000/api/v1';

// 4. iOS SIMULATOR (Desarrollo local)
// const String BASE_URL = 'http://localhost:5000/api/v1';

// 5. WEB/CHROME (Desarrollo local)
// const String BASE_URL = 'http://localhost:5000/api/v1';