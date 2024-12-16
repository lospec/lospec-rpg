# Lospec RPG

A collaborative project for Lospec members.

You may contribute whatever features you wish.

## Current Features

- walking around an empty map as skeddles

# Development

Uses Godot 4.3, but probably safe to keep updated to the lastest stable version.

## Setup

1. Clone the repository
2. Open the project in Godot
3. Run the project

## Contributing

1. Fork the repository
2. Setup
3. Make your changes
4. Commit your changes
5. Push your changes
6. Create a pull request

## Adding Characters

1. Create a new folder in `./characters/`
2. Add a png sprite sheet of all your characters animations
3. Add a copy of `character.tscn` to the world
4. Set the character name and sprite sheet

## TileMap

The tilemap is really just a placeholder, but you can add to it how you wish.
A second tile layer should be added on top for transparent tiles.

# Graphics

The graphics in this game are based on the sprites created for the [Lospec Emoji Comic](https://lospec.com/collabs/lospec-emoji-comics/), which were in turn based off the emoji created for the Lospec Discord server.

## Emoji Style
- uses only colors from the the emoji palette https://lospec.com/palette-list/lospec-emoji
- completely outlined in black (except on bottom of feet)
- very minimal shading (only when necessary for readability)
- black lines should be AAed with single pixels
- avoid mixing colors from separate ramps
- never use black as a fill, only outlines (except for holes, like a mouth or gun barrel)
- no dithering
- 2-4 frames per animation

## Character Sprite Sheets
- 32x32 sprites, centered horizontally and at the bottom of the frame
- no spacing or padding between sprites
- 1 animation per row

row 1: idle
row 2: walk (also uses the first idle frame in between)

## Tileset
- 16x16 tiles
- simple flat style with minimal texture
- no black aside from outlines on a transparent background
- as few tiles for each terrain/object as possible (if it can be done with less it should)