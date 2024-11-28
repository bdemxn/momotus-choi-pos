# Welcome to the official Choi POS as well known as `Momotus Evolv Beta`🚀
> Choi POS or Momotus Evolv Beta is an Open Source Point of Sales where you can ``edit``, ``add`` and ``delete`` items, users, customers and more.

### Requirements:
- ``Dart SDK`` [Official SDK](https://dart.dev/get-dart)
- ``Flutter SDK`` [Official SDK](https://docs.flutter.dev/get-started/install)

### Dev dependencies:
- fluttertoast: ``v8.2.8``
- go_router: ``v14.6.1``
- http: ``v1.2.2``
- provider: ``v6.1.2``

### Specs:
- App version: ``v0.0.7 Unreleased``
- Project storage: ``~600MB``
- Project build: ``~200MB``

### How can I start?
````sh
git clone https://github.com/bdemxn/momotus-choi-pos.git
cd momotus-choi-pos
flutter pub get
````

### Folder Structure:

````
lib/
├── router/
│   └── app_router                # App Router
├── screens/
│   ├── admin/
│   │   ├── customers             # Customer's info
│   │   ├── inventory             # Items' data
│   │   ├── overview              # General POV
│   │   ├── reports               # Data list
│   │   └── users                 # POS User's info
│   ├── app                       # Cashier app
│   ├── forgot                    # Recovery password for users
│   └── login                     # Login form
├── theme/
│   ├── dark_theme
│   └── light_theme
├── widgets/
│   ├── login_form
│   └── sidebar_admin
└── main
````
