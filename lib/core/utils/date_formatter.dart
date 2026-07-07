// Parsea una fecha ISO 8601 del backend (UTC) y la convierte a la hora local
// del dispositivo. Usar en todos los fromJson() en lugar de DateTime.parse().
DateTime parseUtcToLocal(String isoString) =>
    DateTime.parse(isoString).toLocal();
