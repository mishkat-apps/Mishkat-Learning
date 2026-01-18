# Mishkat Learning - Design Guide

This document outlines the design system and UI structure for the Mishkat Learning app, based on the provided mockups.

## Color Palette
- **Primary (Deep Emerald)**: `#0E6B5B` - Used for primary buttons, active states, and heavy background sections.
- **Secondary (Midnight Navy)**: `#0B1324` - Used for headers, primary text, and dark backgrounds.
- **Accent (Warm Gold)**: `#C8A24A` - Used for progress bars, icons, ratings, and highlights.
- **Surface (Soft Sand)**: `#F4F0E6` - Used for page backgrounds and light sections.
- **Success/Completed**: Emerald green variant.
- **Neutral**: Grays for disabled/locked states and secondary text.

## Typography
- **Headings**: Clean, modern Sans-serif (prefer **Outfit** or **Inter** as suggested in prompt). Bold weights for titles.
- **Body**: Regular weights, high readability.
- **Wisdom Quotes**: Serif or italicized fonts for a scholarly feel.

## Key Screens & Components

### 1. Splash / Welcome Screen
- Deep Emerald background with subtle Islamic geometric patterns.
- Centered "MISHKAT" logo with a golden lamp icon.
- Prominent "Welcome to Mishkat Learning" heading.
- Two-button layout: "Get Started" (Filled Emerald) and "Sign In" (Outlined/Transparent).

### 2. Dashboard (Home)
- Header with user profile and greeting (e.g., "Assalamu Alaikum, Ahmad").
- **Continue Learning**: Large card showing current course, progress bar (Gold), and "Resume Study" button.
- **Daily Wisdom**: Quote card with a clean sans-serif/serif mix.
- **Horizontal Scrolls**: "Featured Courses" and "New Additions" with course thumbnails.
- **Bottom Navigation**: Home, Curriculum, Library, Profile.

### 3. Course Overview
- Top: Video preview/trailer with play button.
- Course Title & Rating (Stars + count).
- Quick Stats: Duration, Level, Credential (boxed layout).
- "About this course" section.
- "What you will learn": Checklist with green checkmark icons.
- **Instructor Bio**: Card with avatar, name, and verified status.
- **Syllabus**: Accordion-style modules. Lessons show duration and locked status.
- **Bottom Bar**: Sticky bar with price and "Enroll Now" CTA.

### 4. Lesson Player
- Top: Video player with custom controls.
- Progress bar specifically for the module.
- **Tabs**: Overview, Lessons, Resources.
- **Lesson List**: Clear distinction between Completed (check), Now Playing (music/bar icon), and Locked (lock icon).
- "Ask a Question" Floating Action Button.

### 5. Student Profile
- Header: Avatar with "Seeker" rank/level badge.
- **Stats Grid**: "Courses Done" and "Hours Studied".
- **Certificates Carousel**: Visual cards of earned certificates with download option.
- **Menu List**: Settings, Preferences, Language, Support, Logout.

## UI Patterns
- **Rounded Corners**: Generous border-radius (e.g., 16-24px) for cards and main buttons.
- **Progress Bars**: Dual-tone (Emerald/Gold background with filled section).
- **Cards**: Minimalist, whitespace-focused, using subtle borders or soft shadows.
- **Icons**: Clean outline icons with primary or accent colors.
