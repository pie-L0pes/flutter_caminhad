# Caminhadas

Aplicativo Flutter desenvolvido para o desafio **App Caminhadas** do curso de Desenvolvimento de Sistemas.

O aplicativo permite registrar caminhadas usando localização, mapas, cálculo de rotas, estimativa de distância, tempo e calorias, armazenamento local e fotos feitas pela câmera.

## Funcionalidades

- Splash screen com animação de entrada e saída.
- Tela Home com lista de caminhadas cadastradas.
- Menu lateral com opção de tema claro/escuro.
- Seleção de destino diretamente no mapa.
- Localização atual do aparelho.
- Cálculo de trajeto utilizando OSRM.
- Exibição do trajeto no OpenStreetMap.
- Cálculo da distância.
- Estimativa do tempo de caminhada.
- Estimativa de gasto calórico.
- Modal para informar o título da caminhada.
- Armazenamento local das caminhadas.
- Tela de detalhes.
- Registro de foto pela câmera.
- Persistência da foto localmente.

## Tecnologias

- Flutter
- Dart
- flutter_map
- OpenStreetMap
- OSRM
- Geolocator
- SharedPreferences
- Image Picker

## Estrutura

```text
lib/
├── main.dart
├── models/
│   └── caminhada.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── nova_caminhada_screen.dart
│   └── detalhes_screen.dart
├── services/
│   ├── location_service.dart
│   ├── routing_service.dart
│   └── storage_service.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    ├── caminhada_card.dart
    └── map_widget.dart
```

## Como executar

Instale o Flutter e um dispositivo Android ou emulador.

Depois, dentro da pasta do projeto:

```bash
flutter pub get
flutter run
```

Para gerar o APK:

```bash
flutter build apk --release
```

O APK será gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Observações

O mapa utiliza os tiles do OpenStreetMap.

A rota é calculada pelo serviço público OSRM usando o perfil de caminhada.

A estimativa de calorias foi definida em **60 kcal por quilômetro**, pois o enunciado não fornece peso, idade, sexo ou outra informação necessária para uma estimativa individualizada.

A estimativa de tempo utiliza o tempo retornado pela rota quando disponível.

## Créditos

Projeto desenvolvido por **Pietra Vitória Fernandes Lopes** para a atividade de Desenvolvimento de Sistemas.
"# flutter_caminhad" 
