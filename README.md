# Abaarso Car Rental 🇸🇴🚗
### Kireynta Gaariga Abaarso (Hargeisa, Somaliland)

A production-grade, premium mobile application designed for the Somali car rental market (Hargeisa, Somaliland). Built with **Flutter** and **Firebase**, it features Clean Architecture, Riverpod state management, dual-language localization (English & af Soomaali), localized mobile money payments (EVC Plus, Zaad), and a fully functional role-gated admin control center.

---

## 🌟 Key Features

*   **Dual-Language Localization**: Full dynamic localization for English and Somali (`af Soomaali`) with in-app toggling and state persistence.
*   **Authentication & KYC Module**: Phone OTP verification (+252 & +254 prefixes), user role onboarding, and KYC verification for drivers/customers (profile photo and ID/license uploads).
*   **Cars Fleet & Search**: Real-time Firestore search and filtering (price, category, AC/GPS/4WD features) with offline caching support.
*   **TableCalendar Booking Engine**: Highly customized calendar indicating booked dates (in red) and available dates (in soft green) to prevent overlapping rentals.
*   **Localized Mobile Payments**: Push checkout integrations for Hormuud EVC Plus (+25261) and Telesom Zaad (+25263) with simulated delay, heavy vibrations/success haptic feedback, and automated status transitions.
*   **Currency Side-by-Side**: Automatic dual-currency display showing prices in both USD and Somali Shillings (SOS) at a flat conversion rate of `1 USD = 600 SOS`.
*   **Role-Gated Admin Panel**:
    *   **Interactive Dashboard**: Business KPIs and weekly revenue curve trends using `fl_chart`.
    *   **Fleet CRUD Management**: Real-time vehicle additions, edits, and deletions with input validation.
    *   **Rental Requests Approvals**: Admin command center to transition bookings (`Pending ➔ Approved ➔ Active ➔ Completed`).
    *   **KYC Approval Sheet**: View user documents and verify profiles with a single tap.
    *   **FCM Push Broadcast Centre**: Send simulated or real push notifications targeting specific audiences (All Customers, Drivers, Admins).

---

## 🏗️ Architecture & Directory Structure

This project follows **Clean Architecture** principles separated by feature layers:

```
lib/
  main.dart                    # Entry point & ProviderScope initialization
  core/
    constants/                 # AppColors, AppRoutes, AppStrings
    providers/                 # AppSettings, RouterProvider
    theme/                     # Light Theme, Dark Theme
    utils/                     # SOS/USD Side-by-side Formatters, Haptic/Map Helpers
    widgets/                   # LoadingOverlay, MainNavigationWrapper, Shimmer Skeletons
  features/
    auth/                      # Data, Domain, and Presentation (Login, Register, KYC)
    cars/                      # Data, Domain, and Presentation (Home, Search, Details)
    bookings/                  # Data, Domain, and Presentation (Calendar, Checkout, Details)
    profile/                   # Favorites, Preferences, Account Deletion
    admin/                     # Dashboard, Fleet CRUD, KYC Sheet, FCM Broadcaster
  l10n/                        # app_en.arb, app_so.arb, and generated localizations
```

---

## 🛠️ Setup & Running

### Prerequisites

*   Flutter SDK (v3.0.0 or higher)
*   Dart SDK (v3.0.0 or higher)
*   Android Studio / Xcode (for emulation)

### Installation

1.  Clone the repository and navigate to the project directory:
    ```bash
    cd abaarso_car_rental
    ```
2.  Install all pub dependencies:
    ```bash
    flutter pub get
    ```
3.  Compile localizations (if you make changes to `.arb` files):
    ```bash
    flutter gen-l10n
    ```
4.  Run the application locally:
    ```bash
    flutter run
    ```

---

## ⚡ Firebase & Simulation Mode (Failover)

This application is built to be **fully functional out of the box** without requiring direct Firebase configurations. It contains a modular failover simulation engine:

*   **Auth Sim**: Bypasses the SMS carrier charges by simulating phone verification with standard input responses.
*   **Firestore Sim**: Pre-seeds Land Cruisers, luxury Lexus sedans, Pickups, and test bookings locally into memory if Firebase is not initialized.
*   **Payment Sim**: Simulates Zaad/EVC USSD push delay of 1.5 seconds, then emits success haptic vibrations and triggers status updates.

To connect your own production Firebase instance:
1.  Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in their respective platform directories.
2.  Run the application. The datasources will automatically detect Firebase and disable simulation failovers in favor of real-time Firebase Auth and Cloud Firestore.
3.  Deploy Firestore Security Rules:
    ```bash
    firebase deploy --only firestore:rules
    ```

---

## 🔒 Security Rules (`firestore.rules`)

The system comes pre-configured with granular Firestore rules securing user records:
*   **Users**: Can only read and write their own documents. Admins can read/update all to manage KYC approvals.
*   **Cars**: Open read access to everyone; write access restricted strictly to admins.
*   **Bookings**: Users can create/view their own bookings. Admins can manage all.
*   **Reviews**: Authenticated users can post; only owners or admins can modify/delete them.

---

## 🧪 Verification & Testing

To execute automated unit tests verifying the side-by-side currency formatters, phone validators, and mock payment assertions:
```bash
flutter test
```
