# Finanpolis

Directorio del proyecto Finanpolis. Life-Sim sobre educación Financiera.
---
# Basic Life-Sim Architecture

Game
├── Main
│   ├── GameManager
│   ├── ScenarioManager
│   ├── TimeManager
│   └── SaveManager
│
├── Simulation
│   ├── World
│   │   ├── IsometricGrid
│   │   ├── TileMap
│   │   ├── Furniture
│   │   ├── InteractableObjects
│   │   └── Characters
│   │
│   ├── Player
│   │   ├── Movement
│   │   ├── Needs
│   │   ├── Inventory
│   │   ├── Relationships
│   │   └── Actions
│   │
│   ├── Time
│   │   ├── Day
│   │   ├── Schedule
│   │   └── Events
│   │
│   └── State
│       ├── PlayerState
│       ├── WorldState
│       ├── RelationshipState
│       └── ScenarioState
│
├── Scenarios
│   ├── ScenarioDefinition
│   ├── ScenarioLoader
│   ├── ScenarioContext
│   ├── ScenarioObjectives
│   └── ScenarioConsequences
│
└── Interface
	├── HUD
	├── NeedsPanel
	├── InventoryPanel
	├── DialoguePanel
	├── ScenarioPanel
	└── CalendarPanel

#Generic Scene Structure

Main
├── World
│   ├── TileMap
│   ├── GroundObjects
│   ├── Furniture
│   ├── InteractableObjects
│   ├── Player
│   └── Camera2D
│
├── SimulationController
├── ScenarioController
├── TimeController
└── UI
	├── HUD
	├── NeedsPanel
	├── DialoguePanel
	└── ScenarioPanel

## The architecture has to further modified until reach congurency with the GDD
---
# Building steps
### Build it in this order:

	1 - Create the main scene.
	2 - Add an isometric TileMap.
	3 - Add player movement using grid or world coordinates.
	4 - Add a camera that follows the player.
	5 - Create one interactable object, such as a bed.
	6 - Add a basic interaction system.
	7 - Add a simple time manager.
	8 - Add one player need, such as energy.
	9 - Display the need and time in the UI.
	10 - Save and load the current state only after the loop works.

### A minimal first implementation could use:

Scenes/
├── main.tscn
├── world.tscn
├── player.tscn
└── interactable_object.tscn

Scripts/
├── main.gd
├── world.gd
├── player.gd
├── interaction_system.gd
├── time_manager.gd
└── utilities/
	├── grid_utils.gd
	└── coordinate_utils.gd

Assets/
├── art/
│   ├── sprites/
│   └── tilesets/
├── audio/
└── fonts/

Data/

Start with placeholder graphics. Use simple colored shapes or basic tiles instead of final art. The goal of this first step is to prove that movement, interaction, time, and state changes work together.

### Once this loop works, add the scenario architecture:


Scenario Data
	  ↓
Scenario Manager
	  ↓
Starting World State
	  ↓
Player Actions
	  ↓
State Changes
	  ↓
Scenario Conditions
	  ↓
Events and Consequences

Do not begin by creating many scenarios, characters, objects, or UI screens. First make one complete interaction work from beginning to end. That interaction becomes the foundation for the rest of the game.
---
# Project Folder Structure

This project is organized into separate folders for assets, scenes, scripts, and game data.

## Assets/

Contains the visual, audio, and font resources used throughout the game.

### Assets/art/

Contains the game's artwork and visual resources.

### Assets/art/sprites/

Contains sprites for characters, enemies, objects, items, effects, and other 2D game elements.

### Assets/art/tilesets/

Contains tiles and tileset resources used to create the isometric game world and its environments.

### Assets/audio/

Contains music, sound effects, ambient sounds, and other audio resources used in the game.

### Assets/fonts/

Contains the fonts used for the game's user interface, menus, dialogue, and other text elements.

## Scenes/

Contains Godot scene files that define the structure, components, and reusable elements of the game.

## Scripts/

Contains the GDScript files responsible for controlling game logic, mechanics, systems, and behaviors.

### Scripts/utilities/

Contains reusable helper scripts and general-purpose functions shared across different parts of the game.

## Data/

Contains configuration files and structured game data, such as item information, scenario settings, quests, dialogue, and other gameplay-related resources.
