# FaceCompare

## Introducción

Demo de integración de Regula FaceSDK sobre UIKit. Permite capturar el rostro del usuario y comparar su similitud frente a una imagen seleccionada desde la galería, mostrando el porcentaje de coincidencia de forma visual y sencilla. Se ha priorizado el clean code, la separación en capas y la gestión robusta de errores siguiendo las mejores prácticas para integración de SDKs externos en mobile.

## Funcionalidades Principales

- **Captura facial con liveness**: Detección de rostros reales usando el SDK de Regula
- **Selección de imágenes**: Desde galería o cámara usando PHPicker y UIImagePicker  
- **Comparación facial**: Análisis de similitud entre dos rostros con resultado porcentual
- **Gestión de estados**: UI reactiva con feedback visual durante procesos
- **Manejo de errores**: Alerts informativos y opciones de reintento

## Arquitectura

Arquitectura MVVM con separación clara de responsabilidades. El FaceSDKManager centraliza toda la interacción con el SDK de Regula, mientras que los ViewModels orquestan la lógica de negocio y exponen estado observable para la UI.

## Estructura de Directorios
```
FaceCompare/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Core/
│   ├── Services/
│   │   ├── FaceSDKManager.swift
│   │   └── ImagePickerService.swift
│   ├── Extensions/
│   │   ├── UIViewController+Extensions.swift
│   │   └── UIView+Extensions.swift
│   └── Utils/
│       └── Constants.swift
├── Features/
│   └── FaceComparison/
│       ├── Models/
│       │   ├── FaceComparisonModel.swift
│       │   └── ImageSource.swift
│       ├── ViewModels/
│       │    └── FaceComparisonViewModel.swift
│       └── Views/
│           ├── Main.storyboard
│           └── FaceComparisonViewController.swift
└── Resources/
    ├── Assets.xcassets
    └── LaunchScreen.storyboard
```

## Resumen de Directorios

- **Application**: Punto de entrada y configuración inicial de la app
- **Core/**: Servicios compartidos, extensiones y constantes reutilizables
- **Features/**: Funcionalidad principal de comparación facial con su modelo, vista y viewmodel
- **Resources/**: Assets y recursos visuales

## Principios Clave

- **Separación de responsabilidades**: Manager para SDK, ViewModel para lógica, View para UI
- **Estado observable**: Uso de Combine para comunicación reactiva
- **UI programática**: Layout con StackView y Auto Layout constraints
- **Async/await**: Manejo moderno de concurrencia para operaciones del SDK
- **Gestión centralizada**: Un solo punto de acceso al SDK de Regula

## Flujo de Usuario

1. **Inicialización**: El SDK se inicializa automáticamente al abrir la app
2. **Captura**: Usuario pulsa "Capture Face" → Se abre liveness detection
3. **Selección**: Usuario selecciona segunda imagen desde galería/cámara  
4. **Comparación**: Sistema compara ambas imágenes y muestra porcentaje
5. **Reset**: Usuario puede limpiar todo y empezar de nuevo

## Patrones y Decisiones Técnicas

- **MVVM**: Desacoplamiento entre UI y lógica de negocio
- **Manager centralizado**: `FaceSDKManager` maneja inicialización, captura y comparación
- **UI programática**: Layout con StackView y Auto Layout constraints
- **Async/await**: Para operaciones del SDK y manejo de concurrencia
- **Combine**: Para estado reactivo entre Manager y ViewModel
- **Delegate pattern**: Para comunicación entre servicios y ViewModels

## Gestión de Errores

- Errores de inicialización del SDK
- Fallos en captura (permisos, hardware, calidad)
- Errores en comparación facial  
- Timeouts y cancelaciones de usuario
- Feedback visual con alerts y opciones de reintento

## Componentes del SDK Utilizados

- `FaceSDK.service.initialize()`: Inicialización del SDK
- `FaceSDK.service.startLiveness()`: Captura con detección de vida
- `FaceSDK.service.matchFaces()`: Comparación de similitud facial
- `LivenessConfiguration`: Configuración de liveness pasivo

## Requisitos

- iOS 13+ (requerido por FaceSDK)
- Xcode 14+ y Swift 5.7+
- Regula FaceSDK integrado vía Swift Package Manager

## Instalación de Dependencias

El proyecto requiere dos paquetes SPM de Regula:
- https://github.com/regulaforensics/FaceSDK-Swift-Package
- https://github.com/regulaforensics/FaceCoreBasic-Swift-Package

**Nota**: `FaceCoreBasic` es necesario para las funciones básicas de liveness y comparación facial. Sin él obtienes el error "Core framework missed".

## Ejecución Rápida

1. Clonar el repositorio
2. Abrir el proyecto en Xcode y seleccionar el esquema de la app
3. Ejecutar en dispositivo

## Documentación Oficial
https://docs.regulaforensics.com/develop/face-sdk/mobile/?utm_source=github

## Aspectos a Mejorar o Extender
- Persistencia avanzada con análisis local, guardar un histórico y estadísticas detalladas.
- Instrucciones y feedback en el idioma del usuario.
- Mostrar resultados de similitud no solo como porcentaje sino con barras de progreso, colores o explicaciones para mejorar la UX.

