# Leaf it to me

A small autumn game for mobile, made with Godot. The yard is buried in leaves and more keep falling — swipe them all off the screen to win.

<p align="center">
  <img src="docs/screenshot.png" alt="The autumn yard with a pile of orange leaves at the bottom of the screen" width="300">
</p>

## How to play

- The game starts with a pile of leaves covering the bottom half of the yard.
- Drag a leaf and release it outside the screen to get rid of it. Leaves released inside the yard drop back down.
- A new leaf falls from the top every few seconds, so keep sweeping.
- Once no leaf is left on screen, a check ring fills up. Keep the yard clear for one second and you win.
- From the win screen you can play again or roll the credits.

## Running the game

1. Install [Godot 4.7](https://godotengine.org/download).
2. Clone this repository and open `project.godot` from the Godot project manager.
3. Press **Run Project** (F5).

The game is built for portrait phones (720×1280) and uses the Mobile renderer. On desktop, drag the leaves with the mouse.

## Project structure

| Path | Contents |
| --- | --- |
| `scenes/main.tscn` | The yard: background, walls, leaf spawner, music and the overlay screens |
| `scenes/leaf.tscn` | A single draggable leaf (`RigidBody2D`) |
| `scenes/clearCheck.tscn` | The "Yard looks clear…" ring shown before a win |
| `scenes/gameOverHUD.tscn` | The win card with *Play again* and *Credits* |
| `scenes/creditsScreen.tscn` | The scrolling end-titles credits |
| `scripts/` | The scripts for each scene; `leavesGenerator.gd` drives the game loop |
| `assets/` | Background, leaf sprite, icons, fonts and music |

## Credits

- **Game & music:** Arnaud Ober
- **Art assets:** Designed by Magnific
- **Fonts:** [Fredoka](https://fonts.google.com/specimen/Fredoka) and [Nunito](https://fonts.google.com/specimen/Nunito), under the SIL Open Font License (see `assets/fonts/`)
