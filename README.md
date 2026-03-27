 NextStop
A modern, flexible ridesharing solution for working professionals.
NextStop is a transportation platform designed to model commercial transportation with convenience, networking capabilities, and greater passenger autonomy
. Built for tier-1 and tier-2 African cities, NextStop acts as a "modern Danfo" by allowing passengers to lessen the burden of their transportation costs through shared rides, while guaranteeing the comfort, safety, and reliability they deserve
.
About the Project
In metropolitan cities, public transport is torn between rigid government-owned options and privately controlled ride-hailing apps that offer little autonomy to the passenger
. NextStop introduces a dynamic rideshare model where passengers can initiate a trip, propose a fee, and choose to ride alone or share the cost with up to 3 extra passengers
. Drivers can view requests, negotiate prices in real-time, and efficiently pick up passengers along optimized routes
.
Core Features
Real-Time Price Negotiation: Passengers propose a fare, and drivers can accept, decline, or counter-offer within a time-limited negotiation loop
.
Dynamic Ridesharing: Passengers can choose to ride alone or share the cost with other commuters heading in the same direction
.
Professional Snapshot & Virtual Seat Map: For shared rides, co-riders can view anonymized professional details (industry, job title) of other passengers to foster networking.
Women-Only Rides: Enhanced safety features allowing female passengers to filter and match exclusively with female drivers or female-only shared rides.
Live Route Mapping: Real-time driver tracking, route mapping, and automatic fare calculation based on pick-up (Point A) and drop-off (Point B) locations
.
Tech Stack
Frontend: Flutter (Dart) for Android and iOS cross-platform mobile application
.
Maps & Geolocation: Google Maps Platform (google_maps_flutter SDK, Directions API) (Note: External third-party mapping integration)
.
Backend: Node.js / Express.js with MySQL (Geospatial indexing) (Note: Backend language relies on standard external frameworks).
Real-Time Sync: WebSocket Server 

Interswitch API Integrations (Hackathon Core)
NextStop leverages the robust infrastructure of Interswitch to handle all KYC, authentication, and payment processing securely:
Identity Verification (API Marketplace)
Driver's License Verification API: Used during driver onboarding to verify identity against the FRSC database, ensuring all drivers are licensed and legally compliant
.
NIN Verification API: Validates the National Identity Number of users for enhanced trust and safety
.
Phone Authentication (API Marketplace)
WhatsApp OTP API / Safetoken: Secures user sign-ups by sending real-time OTPs for phone number verification
.
Payment Collection (Quickteller Business)
Web Checkout API: Allows passengers to securely pay their negotiated ride fare using Cards, Transfers, or USSD directly within the Flutter app
.
Transaction Search API: Used server-side to query and verify that a transaction was 100% successful before authorizing a ride
.
Driver Payouts & Escrow Workaround (Send Money)
Send Money (Transfers) API: NextStop securely holds the passenger's payment in its Quickteller wallet (acting as an escrow ledger). Once the trip is marked as "Ended", the backend automatically triggers the Send Money API to disburse the earnings directly to the driver's verified bank account
.
🚀 Getting Started
Prerequisites
Flutter SDK (v3.0+)
Interswitch API Marketplace Account (Client ID & Secret)
Interswitch Quickteller Business Account (Merchant Code & Pay Item ID)
Google Cloud Console Account (Google Maps API Keys)
Installation
Clone the repository:
Install Flutter dependencies:
Configure Google Maps API Keys:
Android: Add your API key to android/app/src/main/AndroidManifest.xml
.
iOS: Add your API key to ios/Runner/AppDelegate.swift
.
Configure Interswitch Credentials: Create a .env file in the root directory and add your test credentials:
Run the application:
Project Deliverables (Hackathon MVP)
Onboarding Pages: Driver/Passenger sign up, document upload (NIN, License), phone verification
.
Driver Dashboard: Route map, available ride requests, negotiation interface, passenger manifest, end trip trigger
.
Passenger Dashboard: Book a ride, choose "Ride Share" or "Ride Alone", price negotiation, view available ride joins
.
Team NextStop
Built with ❤️ for the Interswitch Developer Community x Enyata Hackathon 2026.
Kudirat Ijeoma Ibeabuchi - Flutter Developer, Backend Engineer, Product designer

Timilehin Badiora - Product Manager