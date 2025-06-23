
# ReForm

**ReForm** is an iOS app that helps users improve their squat form using real-time **audio** and **visual feedback**. It uses on-device machine learning to detect common squat mistakes and provide live coaching, making workouts safer and more effective — all with just an iPhone.

---

## 🚀 Features

- 📱 **iOS-native app** built with SwiftUI & CoreML
- 🧠 Real-time squat **form classification** using pose detection
- 🔊 **Voice feedback** to guide and correct your form
- 🎯 Focuses on 3 squat form classes: `Good`, `Knees Over Toes`, and `Knees Inward`
- 📷 Uses only **your iPhone camera** at a 45° angle — no wearables, no cloud, full privacy

---

## 🧰 Tech Stack

- **SwiftUI & UIKit** for UI
  - Uses `@StateObject`, `@ObservedObject`, `ZStack`, `TabView`, etc.
  - UIKit only for low-level `CGContext` drawing
- **AVFoundation** for camera input (30 fps)
- **Vision + CoreML**
  - `VNDetectHumanBodyPoseRequest` detects 17 body keypoints per frame
  - Custom CoreML sequence model classifies pose windows (~30ms latency)
- **Combine** for real-time video processing pipeline
- **CoreGraphics** for fast skeleton rendering

---

## 🧠 How the Model Works

- **Input**: A sequence of 60 body poses (2 seconds @ 30 fps)
- **Data Format**: `MultiArray (Float32 60 × 3 × 18)`  
  - `60` = frames  
  - `3` = x, y, confidence  
  - `18` = body keypoints (nose, neck, shoulders, hips, knees, etc.)
- **Classes**:
  - `Good`
  - `Bad (Knees Over Toes)`
  - `Bad (Knees Inward)`
- **Feedback** is delivered live in both visual and audio formats based on classification results

---

## 🗂 Project Structure

```
Reform (SquatClassifierMLC)
├── App/                        # Main app entry & layout
├── Model/                     # ML classification & pose logic
│   └── Pose/                  # Angle calculation, keypoint utilities
├── Utility/                   # Helper functions
├── Video Capture/             # AVFoundation camera handling
├── Video Processing Chain/    # Real-time ML pipeline
├── ViewModel/                 # Squat state, navigation, voice control
├── Views/                     # UI Components
│   ├── Camera/                # Camera view & overlays
│   ├── Onboarding/            # Intro + instructions
│   └── Summary/               # Post-session result view
```

---

## 📦 Installation

> ⚠️ This app is designed to run on a **real iOS device** due to live camera and CoreML usage.

### Requirements

- Xcode 15+
- iOS 16+
- Swift 5.7+
- Dependencies:
  - [`swift-async-algorithms`](https://github.com/apple/swift-async-algorithms)
  - [`swift-collections`](https://github.com/apple/swift-collections)

### Running the App

1. Clone the repo  
   `git clone https://github.com/aranlv/SquatClassifierMLC.git`

2. Open the project in Xcode:  
   `open SquatClassifierMLC.xcodeproj`

3. Run on a real device (camera required)

---

## 📚 Dataset & Training

- Based on the **Waseda University Action Recognition Dataset**  
  [https://hi.cs.waseda.ac.jp/~ogata/Dataset.html](https://hi.cs.waseda.ac.jp/~ogata/Dataset.html)
- Data was preprocessed into short 1–2 second clips of individual squat reps
- Model trained on 3-class form labeling (Good / Knees Inward / Knees Over Toes)

---

## 🔄 Future Improvements

- Personalize feedback to individual body types
- Make feedback more intuitive (e.g. Pilates-style voice cues)
- Improve visual annotations for real-time corrections
- Train model to adapt over time with user-specific movement history

---

## 🙌 Credits

- Dataset: Waseda University Human Motion Dataset  

---

## 📸 Demo
![Demo](demo.gif)

