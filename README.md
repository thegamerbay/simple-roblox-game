# 🎮 Simple Roblox Game

![Roblox](https://img.shields.io/badge/Roblox-Studio-000000?style=for-the-badge&logo=roblox&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-Language-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![Rojo](https://img.shields.io/badge/Rojo-Sync-FF4B4B?style=for-the-badge)

A basic but complete starting point for a Roblox game, featuring server and client architecture, local environments, and game logic! The project demonstrates an elegant synchronization process between your local IDE (VS Code) and Roblox Studio using **Rojo**.

🔗 **GitHub Repository:** [thegamerbay/simple-roblox-game](https://github.com/thegamerbay/simple-roblox-game)

---

## 🎯 Gameplay & Objectives

This project isn't just a foundation; it comes with a built-in game loop that perfectly demonstrates core client-server interactions in Roblox:

* **Objective:** Collect the glowing yellow orbs (Coins) that spawn randomly around the map.
* **Mechanics:** 
  * As soon as a player's character touches an orb, it is instantly collected and destroyed.
  * The player's **Leaderstats** track the collected coins and update their score on the Leaderboard in the top-right corner.
  * The server then automatically spawns a brand new coin nearby.
* **Technical Highlights:** This loop acts as a brilliant, easy-to-read example of Server-Side Parts creation, `Touched` events, real-time GUI/Leaderboard updates, and keeping the game state secure on the server while the client renders it.

---

## ⚡ Setup Guide

The development workflow here mirrors classic web or software development: we use a local server running inside VS Code that streams our code in real-time straight to the client (Roblox Studio).

The easiest and most popular way to use Rojo is via the official extension for **Visual Studio Code**.

### Step 1: Getting the Project

1. Open your terminal or command prompt.
2. Clone the repository to your computer by running:
   ```bash
   git clone https://github.com/thegamerbay/simple-roblox-game.git
   ```
3. Open the newly created `simple-roblox-game` folder in **VS Code**.

### Step 2: Installing Rojo in VS Code

1. In VS Code, open the **Extensions** panel (`Ctrl+Shift+X` / `Cmd+Shift+X`).
2. Type **Rojo** into the search bar.
3. Find the extension authored by **evaera** (the official one) and click **Install**.

### Step 3: Installing the Roblox Studio Plugin

For Roblox Studio to receive files sent from VS Code, the receiving part of the plugin must be installed. This is safest to do straight from VS Code:

1. In VS Code, open the **Command Palette** by pressing `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac).
2. Type in the command: `Rojo: Install Roblox Studio Plugin` and hit **Enter**.
3. The extension will automatically install the necessary plugin right into the correct directory on your computer.

### Step 4: Starting the Rojo Server locally

1. Ensure you currently have your project folder open in VS Code.
2. Open the **Command Palette** (`Ctrl+Shift+P`) and type: `Rojo: Start server`.
3. *Alternatively*, just click the **Rojo** button down in your VS Code **Status Bar** (bottom panel) and select `default.project.json`.
4. The server will start (usually on port `34876`), and VS Code will begin tracking any changes you make to your files.

### Step 5: Connecting Roblox Studio

1. Open **Roblox Studio** and create a brand new empty place (using the **Baseplate** template).
2. In the top navigation menu, head over to the **Plugins** tab.
3. Locate the **Rojo** icon and click on it. A small plugin window will pop up.
4. Simply click the **Connect** button in this window.
5. *Hogwarts Magic:* Check your **Explorer** window on the right. Your `GameLogic` and `ClientInit` scripts should have instantly mapped themselves into `ServerScriptService` and `StarterPlayerScripts` respectively!

### Step 6: Playtesting the Game

1. In Roblox Studio, click **Play** (`F5`) on either the Home or Test tab.
2. Your **Output** window should greet you with the welcome message from your local script.
3. On the map, you will spot a green baseplate and a glowing yellow neon sphere dropping from above.
4. Run your character over to touch the sphere — it will disappear, and you'll be rewarded with **1 coin** in the top right leaderboard corner! In just a second, a brand new sphere will spawn for you to collect.


---

## 📄 License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute this project as you see fit.
