# 🌍 Nyks Entity Debugger (RedM)

![Framework](https://img.shields.io/badge/framework-Standalone-green) ![RedM](https://img.shields.io/badge/RedM-RDR3-red)

**Nyks Entity Debugger** is a standalone developer tool designed to solve a common problem: *"Which script spawned this object/NPC?"*

It helps you identify the **Script Owner**, **Model Hash**, and **Exact Coordinates** of any entity. It also generates ready-to-use search queries for Visual Studio Code directly in your F8 Console.

## 📸 Preview

<img width="1657" height="803" alt="image" src="https://github.com/user-attachments/assets/8cd2436a-cede-4db0-9d5d-e9096b04c76b" />


## 🔥 Features

* ✅ **Visual Info:** Displays Script Name, Model Hex, and Coordinates in 3D text above entities.
* ✅ **Source Detection:** Detects if an entity is from a **Script**, a **Map (YMAP)**, or a **Random World Event**.
* ✅ **Smart Logger:** The `/getinfo` command prints exact search queries (Hash, Vector3, X Coord) to the F8 Console.
* ✅ **Optimized:** Runs at **0.00ms** when not in use.
* ✅ **Standalone:** Works with VORP, RedEM:RP, QBR, RSG, and custom frameworks.

## 🛠️ How to Use (Step-by-Step)

The fastest way to find a script is by searching for the **X Coordinate**. Here is the workflow:

### Step 1: In-Game Detection
1.  Go near the object or NPC you want to investigate.
2.  Type `/nyksdebug` to enable visual mode.
3.  Type `/getinfo` to copy the details.
4.  Open your **F8 Console**. Look for the line **"3. X Coordinate (Fast)"** and copy that number (e.g., `1245.55`).

### Step 2: Finding it in VS Code
1.  Open **Visual Studio Code**.
2.  **Drag and drop** your server's `resources` folder into the VS Code window (this loads all your scripts).
3.  Press `CTRL + SHIFT + F` (Global Search).
4.  Paste the **X Coordinate** (e.g., `1245.55`) into the search bar.
5.  *(Tip)* In the "Files to include" box, type `*.lua` to search only in script files.
6.  **Bingo!** The search result will show you the exact file and line number (e.g., `x = 1245.55` or `vector3(1245.55, ...)`). That file is your target script.

## 📥 Installation

1.  Download the files.
2.  Put the `nyks_debug` folder into your server's `resources` directory.
3.  Add the following line to your `server.cfg`:

```cfg
ensure nyks_debug
