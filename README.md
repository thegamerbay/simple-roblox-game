# 🎮 Simple Roblox Game

![Roblox](https://img.shields.io/badge/Roblox-Studio-000000?style=for-the-badge&logo=roblox&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-Language-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![Rojo](https://img.shields.io/badge/Rojo-Sync-FF4B4B?style=for-the-badge)

<div align="center">

[![CI](https://github.com/thegamerbay/simple-roblox-game/actions/workflows/ci.yml/badge.svg)](https://github.com/thegamerbay/simple-roblox-game/actions/workflows/ci.yml)
[![codecov](https://codecov.io/github/thegamerbay/simple-roblox-game/graph/badge.svg?token=YOUR_CODECOV_TOKEN)](https://codecov.io/github/thegamerbay/simple-roblox-game)
[![Release](https://img.shields.io/github/v/release/thegamerbay/simple-roblox-game)](https://github.com/thegamerbay/simple-roblox-game/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

A basic but complete starting point for a professional Roblox game, featuring modular server architecture, unit testing, and continuous integration! The project demonstrates an elegant synchronization process between your local IDE (VS Code) and Roblox Studio using **Rojo**, strict package management using **Wally**, and toolchain management using **Aftman**.

🔗 **GitHub Repository:** [thegamerbay/simple-roblox-game](https://github.com/thegamerbay/simple-roblox-game)

---

## 🎯 Gameplay & Objectives

This project isn't just a foundation; it comes with a built-in game loop that perfectly demonstrates core client-server interactions in Roblox:

* **Objective:** Collect the glowing coins that spawn randomly around the map.
* **Mechanics:** 
  * Coins look like real flat coins (cylinders) and feature a smooth hovering and rotating animation.
  * As soon as a player's character touches a coin, it plays a pleasant sound, emits spark particles, and is instantly collected.
  * There's a **20% chance** to spawn a **Rare Red Coin** that grants **5 points** instead of the usual 1 point for a yellow coin!
  * The player's **Leaderstats** track the collected coins and update their score on the Leaderboard in the top-right corner.
  * The server then automatically spawns a brand new coin nearby.
* **Technical Highlights:** This loop acts as a brilliant, easy-to-read example of creating an isolated, testable **ModuleScript** (`CoinManager.lua`), utilizing `TestEZ` for specifications, and securely keeping the game state on the server (`GameLogic.server.lua`).

---

## 🛠️ Tech Stack & Tooling

This project uses modern Roblox development standards:
* **[Rojo](https://rojo.space/)**: Syncs external files into Roblox Studio.
* **[Aftman](https://github.com/LPGhatguy/aftman)**: Cross-platform toolchain manager for Roblox CLI tools (Rojo, Wally, Selene).
* **[Wally](https://wally.run/)**: The package manager for Roblox. We use it to pull our testing framework, **TestEZ**.
* **[Selene](https://kampfkarren.github.io/selene/)**: A blazing fast linter crafted specifically for Luau and Roblox standard libraries.
* **[GitHub Actions](https://github.com/features/actions)**: Automated CI/CD pipelines checking code quality, tests, and publishing `.rbxlx` places on releases.  Codecov integration automatically comments on pull requests.

---

## ⚡ Setup Guide

### Step 1: Getting the Project & Tools
1. Clone the repository: `git clone https://github.com/thegamerbay/simple-roblox-game.git`
2. Open the folder in VS Code.
3. Install the tools using Aftman:
   ```bash
   aftman install
   ```
4. Install Roblox library dependencies using Wally:
   ```bash
   wally install
   ```

### Step 2: Running Rojo
1. Install the official **Rojo** extension by `evaera` in VS Code.
2. Open the VS Code Command Palette (`Ctrl+Shift+P`) and choose `Rojo: Start server`.

### Step 3: Connecting Roblox Studio
1. Open up an empty modern **Baseplate** in Roblox Studio.
2. Under the **Plugins** tab, click **Rojo** and then **Connect**.
3. *Magic!* Your scripts and Wally packages instantiate perfectly into `ServerScriptService` and `ReplicatedStorage`.

### Step 4: Playtesting & Unit Testing
1. Press **Play** (`F5`) in Roblox Studio.
2. In the Output window, you will immediately see the **TestEZ runner** executing our `CoinManager.spec.lua` tests and turning green!
3. Run into the floating coin to pick it up and see your points increase on the leaderboard.
4. *Note: If you publish the game, the test runner detects it is no longer in Studio and safely exits without performance hits.*

### 🔍 Linting Locally
To run the Selene linter locally before pushing code:
```bash
selene src
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute this project as you see fit.
