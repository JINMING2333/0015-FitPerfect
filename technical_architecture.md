# Technical Architecture - FitPerfect App

## Overview
FitPerfect is built using Flutter framework with integrated ML capabilities for real-time pose detection and comparison.

## Core Components

### 1. Frontend Layer (Flutter)
- **UI Components**
  - Custom widgets for camera preview
  - Pose overlay visualization
  - Real-time feedback display
  - Exercise selection interface
  
- **State Management**
  - Provider pattern for app-wide state
  - Local state management for UI components

### 2. ML Processing Layer
- **MediaPipe Integration**
  - Real-time pose detection
  - 33 body landmarks tracking
  - 3D coordinate mapping

- **Pose Analysis Engine**
  - Angle calculation between joints
  - Pose similarity scoring
  - Real-time feedback generation

### 3. Data Management
- **Local Storage**
  - SQLite for user data
  - Shared Preferences for app settings
  - Local caching of standard poses

- **Standard Pose Database**
  - Pre-recorded correct poses
  - Pose metadata and instructions
  - Reference angles and positions

### 4. Core Features
- Real-time pose detection
- Pose comparison algorithm
- Score calculation
- Visual feedback system
- Progress tracking

## Data Flow
1. Camera input → MediaPipe processing
2. Pose detection → Landmark extraction
3. Comparison with standard poses
4. Real-time feedback generation
5. Score calculation and display

## Technical Stack
- Flutter (UI Framework)
- MediaPipe (Pose Detection)
- SQLite (Local Storage)
- Provider (State Management)
- Custom algorithms for pose comparison

## Performance Considerations
- Optimized for real-time processing
- Efficient memory management
- Smooth UI rendering
- Battery consumption optimization 