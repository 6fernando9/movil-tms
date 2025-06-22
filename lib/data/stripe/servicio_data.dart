class ServicioTest{
  static const Map<String, dynamic> jsonService = {
    "embalaje": false,
    "tipo_viaje_id": 1,
    "tipo_residencia_id": 2,
    "origen": {
      "latitud": 1232131.1,
      "longitud": -242343.2,
      "str": "El torno,calle X,Barrio Y,casa Z"
    },
    "destino": {
      "latitud": -234234.1,
      "longitud": -123211.2,
      "str": "Cotoca,calle X,Barrio Y,casa Z"
    },
    "fecha_reserva": "2025-05-10 16:22:00",
    "distancia": 312,
    "inmuebles": [
      {
        "id": 3,
        "cantidad": 3,
        "formularios": [
          {
            "largo": 0.7,
            "ancho": 0.7,
            "alto": 1.8,
            "peso": 70
          },
          {
            "largo": 2,
            "ancho": 0.9,
            "alto": 0.9,
            "peso": 50
          },
          {
            "largo": 1,
            "ancho": 0.65,
            "alto": 1.5,
            "peso": 40
          }
        ]
      },
      {
        "id": 5,
        "cantidad": 2,
        "formularios": [
          {
            "largo": 1.2,
            "ancho": 0.6,
            "alto": 0.75,
            "peso": 40
          },
          {
            "largo": 0.5,
            "ancho": 0.4,
            "alto": 0.3,
            "peso": 8
          }
        ]
      }
    ],
    "vehiculo_id": 29,
    
  };

}
