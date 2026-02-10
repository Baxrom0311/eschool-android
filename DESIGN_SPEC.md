# 🎨 Login Screen - Design Specification

## Visual Layout

```
┌─────────────────────────────────────────┐
│                                         │
│         ╔═══════════════════╗          │  ← Blue Gradient Top (40%)
│         ║                   ║          │    Colors: #2E5BFF → #5B8DEE
│         ║    [SCHOOL ICON]  ║          │    Border Radius: 0 0 40px 40px
│         ║                   ║          │
│         ╚═══════════════════╝          │
│                                         │
│        Xush kelibsiz!                   │  ← White text, 32px, Bold
│        Tizimga kirish                   │  ← White text, 16px, Regular
│                                         │
│    ┌───────────────────────────────┐   │
│    │                               │   │  ← White Floating Card
│    │  ┌─────────────────────────┐ │   │    Elevation: 8
│    │  │ 👤 Telefon/Login        │ │   │    Border Radius: 24px
│    │  └─────────────────────────┘ │   │    Padding: 24px
│    │                               │   │
│    │  ┌─────────────────────────┐ │   │
│    │  │ 🔒 Parol         [👁]    │ │   │
│    │  └─────────────────────────┘ │   │
│    │                               │   │
│    │         Parolni unutdingizmi? │   │  ← Text Button
│    │                               │   │
│    │  ┌─────────────────────────┐ │   │
│    │  │       KIRISH            │ │   │  ← Primary Button
│    │  └─────────────────────────┘ │   │    Height: 56px
│    │                               │   │    Border Radius: 16px
│    │  ─────────  yoki  ─────────  │   │  ← Divider
│    │                               │   │
│    │  ┌─────────────────────────┐ │   │
│    │  │ [G] Google orqali kirish│ │   │  ← Outlined Button
│    │  └─────────────────────────┘ │   │
│    │                               │   │
│    │  ┌─────────────────────────┐ │   │
│    │  │ [QR] QR kod orqali kirish│ │   │  ← Outlined Button
│    │  └─────────────────────────┘ │   │
│    │                               │   │
│    │  Hisobingiz yo'qmi?           │   │
│    │  Ro'yxatdan o'tish            │   │  ← Text Button (Bold)
│    │                               │   │
│    └───────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

---

## Color Specifications

### Primary Colors
```css
Royal Blue:       #2E5BFF  /* Primary buttons, top section */
Secondary Blue:   #5B8DEE  /* Gradient end, accents */
Dark Blue:        #1C3FAA  /* Hover states */
```

### Neutral Colors
```css
White:            #FFFFFF  /* Card background, text on blue */
Background:       #F5F7FA  /* Page background */
Card Background:  #FFFFFF  /* Floating card */
```

### Text Colors
```css
Text Primary:     #1A202C  /* Main text */
Text Secondary:   #718096  /* Labels, hints */
Text Hint:        #A0AEC0  /* Placeholder text */
```

### Border & Divider
```css
Border:           #E2E8F0  /* Input borders */
Divider:          #EDF2F7  /* Horizontal lines */
```

### Status Colors
```css
Success:          #00C48C  /* Success messages */
Danger:           #FF5757  /* Error messages */
Warning:          #FFB800  /* Warnings */
```

---

## Typography

### Font Family
```css
Primary Font: Roboto (or system default)
Fallback: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif
```

### Text Styles

#### Headings
```css
H1 (Welcome Title):
  font-size: 32px
  font-weight: 700 (Bold)
  color: #FFFFFF
  letter-spacing: 0.5px

H2 (Subtitle):
  font-size: 16px
  font-weight: 400 (Regular)
  color: #FFFFFF (90% opacity)
```

#### Body Text
```css
Label:
  font-size: 13px
  font-weight: 600 (Semi-bold)
  color: #718096

Input Text:
  font-size: 15px
  font-weight: 400 (Regular)
  color: #1A202C

Button Text:
  font-size: 15-16px
  font-weight: 600 (Semi-bold)
  color: #FFFFFF (primary) or #2E5BFF (outlined)
```

---

## Spacing System

### Padding
```css
Card Padding:        24px
Input Padding:       16px (horizontal), 16px (vertical)
Button Padding:      16px (vertical)
Section Padding:     24px (horizontal)
```

### Margins
```css
Between Inputs:      20px
Between Sections:    24px
Before Divider:      24px
After Divider:       24px
Bottom of Card:      16px
```

### Gaps
```css
Icon to Text:        8px
Label to Input:      8px
Title to Subtitle:   8px
```

---

## Border Radius

```css
Top Section:         0 0 40px 40px  /* Bottom left & right only */
Card:                24px
Primary Button:      16px
Outlined Button:     16px
Input Fields:        12px
Avatar/Icon Circle:  50% (circular)
```

---

## Elevation & Shadows

### Card Shadow
```css
elevation: 8
shadow-color: rgba(0, 0, 0, 0.1)
shadow-offset: 0px 4px
shadow-blur: 16px
```

### Top Section
```css
No shadow (flat design)
```

### Buttons
```css
Primary Button:
  elevation: 2
  shadow-color: rgba(46, 91, 255, 0.3)

Outlined Button:
  elevation: 0
  border: 1.5px solid #E2E8F0
```

---

## Component Specifications

### 1. Top Blue Section
```dart
Height: 40% of screen height
Background: Linear Gradient
  - Start: #2E5BFF (top-left)
  - End: #5B8DEE (bottom-right)
Border Radius: 0 0 40px 40px
Content: Centered vertically
  - Icon: 100x100px circle, white with 20% opacity background
  - Title: "Xush kelibsiz!" (32px, bold, white)
  - Subtitle: "Tizimga kirish" (16px, regular, white 90%)
```

### 2. White Floating Card
```dart
Position: Overlaps top section by 40px
Margin: 24px horizontal
Padding: 24px all sides
Background: #FFFFFF
Border Radius: 24px
Elevation: 8
Shadow: 0px 4px 16px rgba(0,0,0,0.1)
```

### 3. Input Fields
```dart
Height: Auto (based on content)
Padding: 16px horizontal, 16px vertical
Border: 1px solid #E2E8F0
Border Radius: 12px
Background: #FFFFFF
Font Size: 15px
Icon Size: 22px
Icon Color: #A0AEC0

Focus State:
  Border: 2px solid #2E5BFF
  Border Radius: 12px
```

### 4. Primary Button ("Kirish")
```dart
Width: 100% (fill parent)
Height: 56px
Background: #2E5BFF
Border Radius: 16px
Elevation: 2
Text: "Kirish"
  - Font Size: 16px
  - Font Weight: 600
  - Color: #FFFFFF

Loading State:
  - Show CircularProgressIndicator (white, 24x24px)
  - Disable button

Disabled State:
  - Background: #2E5BFF with 50% opacity
```

### 5. Outlined Buttons (Google, QR)
```dart
Width: 100% (fill parent)
Height: 56px (or auto with padding: 16px vertical)
Background: Transparent
Border: 1.5px solid #E2E8F0
Border Radius: 16px
Elevation: 0
Icon Size: 24px
Text:
  - Font Size: 15px
  - Font Weight: 600
  - Color: #1A202C

Hover State:
  - Background: #F5F7FA
  - Border: 1.5px solid #2E5BFF
```

### 6. Divider
```dart
Height: 1px
Color: #EDF2F7
Margin: 24px vertical
With Text:
  - Text: "yoki"
  - Font Size: 14px
  - Color: #718096
  - Padding: 0 16px
```

### 7. Text Buttons
```dart
Padding: 8px horizontal, 4px vertical
Text:
  - Font Size: 14-15px
  - Font Weight: 500-700
  - Color: #2E5BFF

Hover State:
  - Background: rgba(46, 91, 255, 0.1)
  - Border Radius: 8px
```

---

## Responsive Behavior

### Mobile (< 600px)
```css
Top Section: 40% height
Card Margin: 16px
Card Padding: 20px
Font Sizes: As specified
```

### Tablet (600px - 1024px)
```css
Top Section: 40% height
Card Margin: 32px
Card Padding: 24px
Max Card Width: 500px (centered)
```

### Desktop (> 1024px)
```css
Top Section: 40% height
Card Margin: Auto (centered)
Card Padding: 32px
Max Card Width: 450px
```

---

## Animations & Transitions

### Button Press
```dart
Duration: 150ms
Curve: easeInOut
Effect: Scale down to 0.95
```

### Input Focus
```dart
Duration: 200ms
Curve: easeOut
Effect: Border color change + width increase
```

### Loading State
```dart
Duration: Infinite
Effect: Circular progress indicator rotation
```

### Screen Transitions
```dart
Duration: 300ms
Curve: easeInOut
Effect: Fade + slide from right
```

---

## Accessibility

### Minimum Touch Targets
```css
Buttons: 48x48px minimum
Input Fields: 48px height minimum
Icons: 24x24px minimum
```

### Contrast Ratios
```css
White on Royal Blue: 4.5:1 (AA compliant)
Text Primary on White: 12:1 (AAA compliant)
Text Secondary on White: 4.5:1 (AA compliant)
```

### Screen Reader Labels
```dart
Input Fields: Proper labels ("Telefon raqam yoki login")
Buttons: Descriptive text ("Kirish tugmasi")
Icons: Semantic descriptions
```

---

## Implementation Checklist

- [x] Blue curved top section (40% height)
- [x] Gradient background (#2E5BFF → #5B8DEE)
- [x] White floating card with 24px radius
- [x] Card elevation (8) and shadow
- [x] Input fields with icons
- [x] Password visibility toggle
- [x] Primary button (56px height, 16px radius)
- [x] Outlined buttons for Google/QR
- [x] Divider with "yoki" text
- [x] Text buttons for links
- [x] Form validation
- [x] Loading states
- [x] Error handling
- [x] Responsive layout
- [x] Proper spacing (24px, 20px, 16px)
- [x] Typography (Roboto, proper sizes)
- [x] Color consistency
- [x] Accessibility (touch targets, contrast)

---

## Code Reference

**File**: `lib/presentation/screens/auth/login_screen.dart`

**Key Sections**:
1. Lines 82-145: Blue curved top section
2. Lines 147-410: White floating card
3. Lines 173-188: Username input
4. Lines 191-207: Password input
5. Lines 234-242: Primary button
6. Lines 277-322: Google button
7. Lines 326-361: QR button

**Reusable Components**:
- `CustomTextField`: Input fields with validation
- `CustomButton`: Primary action button
- `OutlinedButton.icon`: Secondary action buttons

---

**This is the exact design implemented in the Login Screen!**

Use this as your reference for:
- Register Screen
- Forgot Password Screen
- Any other auth screens

**Consistency is key!** 🎨
