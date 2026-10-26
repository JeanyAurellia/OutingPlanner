# 🗺️ OutingPlanner

> Plan every stop, manage your time, and remember every essential. ⏱️📍🎒

OutingPlanner is a native iOS application for organizing an outing from preparation to completion. It combines a time-based itinerary, searchable destination data, destination budgets, a calendar, local reminders, and reusable packing checklists in one place.

## 💡 Background

This project began from a personal difficulty: when traveling or going out, I often struggle to allocate enough time for every destination. Without a clear schedule, one stop can take longer than expected and another place that I wanted to visit may be missed entirely.

Preparation creates a second problem. I also tend to leave behind important belongings that should have been packed before leaving. OutingPlanner was created to address both situations: it gives every destination a place in a timeline and provides reusable belonging lists that can be checked for each individual outing.

## 🎯 Goals

- Make multi-destination outings easier to plan and follow.
- Let users choose a real place and derive its name, address, and purpose from place data.
- Give each destination a clear visit time, note, and budget.
- Reduce missed destinations through a chronological itinerary and reminders.
- Reduce forgotten belongings through reusable, outing-specific checklists.
- Keep outing information available locally in a simple native iOS experience.

## ✨ Features

### 🗓️ Outing management

- Create an outing with a name and an optional date.
- Keep outings without a date as drafts.
- View a dashboard containing up to three upcoming outings and three drafts.
- Open full Upcoming and Draft lists.
- Edit or delete an existing outing.
- Automatically delete an outing's related destinations and checklist items when the outing is deleted.

### 📍 Itinerary and destinations

- Add multiple destinations to an outing.
- Search for places in Indonesia through the Geoapify Geocoding API.
- Select a search result instead of entering a destination name and address manually.
- Derive the destination purpose from its Geoapify category:
  - `catering` becomes `Food`;
  - `commercial` becomes `Shopping`;
  - sport-related categories become `Sport`;
  - museum categories become `Museum`;
  - tourism and entertainment categories become `Entertainment`; and
  - uncategorized results become `Others`.
- Add a visit time, optional notes, and an estimated budget in Indonesian rupiah.
- Display destinations chronologically by visit time.
- Edit destination details directly from the itinerary.
- Mark destinations as completed.
- See destination count, completed count, and total estimated budget at a glance.

The Places service also supports category-based recommendations around a coordinate. The recommendation and favorite-place views are still under development and are not part of the main app flow yet.

### 🎒 Belonging checklists

- Create reusable belonging-list templates with a name and SF Symbol icon.
- Add, edit, and delete items in each template.
- Attach one or more templates to an outing.
- Copy template items into an independent outing checklist, so checking an item for one outing does not modify the original template.
- Group attached items by their source category and show completion progress per category.
- Automatically provide an **Everyday Carry** list containing common essentials such as a wallet, keys, phone, charger or power bank, water, and tissues.

### 📅 Calendar

- Browse outings in a custom monthly calendar.
- See an indicator on dates that contain an outing.
- Select a date to view all outings planned for that day.
- Navigate directly from a calendar event to its outing details.

### 🔔 Notifications

- Optionally receive an outing reminder one day before the outing begins.
- Optionally receive a reminder before each destination.
- Configure destination reminders for 5, 10, 15, 30, 60, or 120 minutes beforehand.
- Send a test notification from Settings.
- Automatically reschedule relevant reminders when outings or destinations change.

Notification permission must be granted by the user. Reminders whose calculated delivery time has already passed are not scheduled.

## 🧭 App Structure

The application has three primary tabs:

| Tab | Purpose |
| --- | --- |
| **Outing** | Create and browse upcoming or draft outings, then manage their itinerary and belongings. |
| **Calendar** | Browse dated outings by month and day. |
| **Settings** | Configure notifications and manage reusable belonging-list templates. |

The codebase follows a feature-oriented structure:

```text
OutingPlanner/
├── App/                         # App entry point and root tab navigation
├── Core/Helpers/                # Color and date/currency formatting helpers
├── Features/
│   ├── Outings/
│   │   ├── Models/              # Outing, Destination, and outing checklist models
│   │   ├── Repositories/        # Outing persistence and reminder coordination
│   │   └── Views/               # Lists, forms, details, and attachment sheet
│   ├── Belonging/
│   │   ├── Models/              # Reusable list and item models
│   │   ├── Repositories/        # Belonging-list persistence operations
│   │   └── Views/               # Template list and item management
│   ├── Calendar/Views/          # Monthly calendar and event cards
│   ├── Places/
│   │   ├── Models/              # Place results and Geoapify response models
│   │   ├── Repositories/        # Favorite-place persistence scaffold
│   │   ├── Services/            # Geoapify search and recommendation requests
│   │   ├── ViewModels/          # Search, loading, and error state
│   │   └── Views/               # Place picker and in-progress place views
│   └── Settings/
│       ├── Managers/            # Local notification scheduling
│       └── Views/               # Notification and checklist settings
├── Resources/                   # App icon and asset catalog
└── Shared/Components/           # Reusable buttons and cards
```

## 🗃️ Data Model

OutingPlanner uses SwiftData for on-device persistence.

| Model | Responsibility |
| --- | --- |
| `Outing` | Stores the outing name, optional date, creation date, destinations, and outing-specific belonging items. |
| `Destination` | Stores a stop's schedule, purpose, location, notes, budget, and completion state. |
| `BelongingList` | Represents a reusable checklist template and its icon. |
| `BelongingItem` | Represents an item inside a reusable template. |
| `OutingBelongingItem` | Stores a copied checklist item and its independent completion state for one outing. |

`Outing` owns its destinations and outing-specific belonging items with cascade deletion. `BelongingList` similarly owns its reusable items.

`PlaceResult` is a transient API result rather than a SwiftData model. When a user selects a place, the app copies its name, address, and derived purpose into a `Destination` alongside the schedule entered in the form.

## 🛠️ Technology Stack

- **Language:** Swift 5
- **UI:** SwiftUI
- **State management:** Observation
- **Persistence:** SwiftData
- **Networking:** URLSession and async/await
- **Places data:** Geoapify Geocoding and Places APIs
- **Notifications:** UserNotifications
- **Testing:** Swift Testing and XCTest/XCUITest
- **IDE:** Xcode
- **Third-party packages:** None

## ✅ Requirements

- macOS with Xcode capable of building the configured SDK
- iOS or iPadOS 26.5 or later, as currently configured in the project
- An iPhone/iPad simulator or a physical device
- A Geoapify API key for place search and recommendation requests
- Notification permission for reminder features

> If iOS 26.5 is not available in your Xcode installation, update the deployment target in the project settings to an SDK supported by your local environment and verify API compatibility.

## 🚀 Getting Started

1. Clone or download this repository.
2. Open `OutingPlanner.xcodeproj` in Xcode.
3. Select the `OutingPlanner` scheme.
4. Open **Product → Scheme → Edit Scheme → Run → Arguments**.
5. Add an enabled environment variable named `GEOAPIFY_API_KEY` and use your Geoapify API key as its value.
6. Choose an iPhone/iPad simulator or a connected device.
7. Press **Run** (`⌘R`).
8. Allow notifications when prompted if you want outing and destination reminders.

No package installation is required. Keep the API key out of Swift source files and do not commit it to the repository.

## 📖 How to Use

1. Open the **Outing** tab and tap the add button.
2. Enter an outing name. Select a date to make it a scheduled outing, or leave the date empty to keep it as a draft.
3. Open the outing and add a destination from the **Itinerary** tab.
4. Search for a place and select a result. Its name, address, and purpose are filled automatically.
5. Assign a visit time, budget, and optional notes; destinations appear in chronological order.
6. Open the **Belonging** tab and attach any reusable checklist needed for the outing.
7. Check destinations and belongings as they are completed or prepared.
8. Use **Calendar** to find plans by date.
9. Use **Settings** to manage checklist templates and reminder preferences.

## 🧪 Building and Testing from the Command Line

Inspect the available targets and schemes:

```bash
xcodebuild -list -project OutingPlanner.xcodeproj
```

Build for an installed simulator runtime:

```bash
xcodebuild \
  -project OutingPlanner.xcodeproj \
  -scheme OutingPlanner \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

Run the test targets:

```bash
xcodebuild \
  -project OutingPlanner.xcodeproj \
  -scheme OutingPlanner \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

Replace the simulator name with one installed on your machine. The Geoapify integration test requires `GEOAPIFY_API_KEY` in the active test-plan environment. The current unit test calls the recommendation endpoint and verifies that it returns at least one place. UI test files are still mostly scaffolding.

## 🔐 Persistence and Privacy

- Outings, destinations, and belonging lists are stored locally through SwiftData.
- Place searches and recommendation requests are sent to Geoapify. Search text and coordinates used for recommendations may leave the device as part of those requests.
- Notification preferences are stored locally through `UserDefaults`.
- Reminder requests are managed by the system notification center.
- The current project does not include an account system, analytics SDK, or third-party package.
- During development, the Geoapify key is read from the `GEOAPIFY_API_KEY` environment variable rather than stored in source code.

During development, if the SwiftData schema cannot be opened, the current app initialization attempts to remove the incompatible local store and create a new one. This can erase existing local development data after a model-schema change.

## 🔭 Current Limitations and Future Improvements

- Add meaningful unit tests for repositories, date calculations, budgets, and checklist copying.
- Add UI tests for the primary outing and belonging workflows.
- Complete the recommendation and favorite-place interfaces and connect them to the app navigation.
- Replace the development environment-variable setup with a production-ready API-key strategy before distribution.
- Improve validation and user-facing persistence error handling.
- Support custom destination categories.
- Add duration and travel-time estimation between destinations.
- Add itinerary reordering and conflict detection.
- Add maps or route integration.
- Add data export, backup, or device synchronization.
- Complete localization so the interface consistently supports English and Indonesian.
- Review notification date composition so destination reminders always align with the outing's selected calendar date.
- Replace destructive development-time store recovery with a production-ready SwiftData migration strategy.

## 🚧 Project Status

OutingPlanner is an actively developed personal project. Its core outing, itinerary, place-search, calendar, notification, and belonging-checklist flows are implemented. Recommendations, favorites, broader test coverage, localization, migration, and route planning remain in development.

## 👩‍💻 Author

Created by **Jeany Aurellia**.
