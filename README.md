<div align="center">

<img src="https://tr.rbxcdn.com/180DAY-4eaaaad3404dd5f87934eee6c3fd0393/768/432/Image/Webp/noFilter" width="120" alt="Script Brainrot Logo"/>

# Script Brainrot
### Tsunami Brainhort — Roblox Script

[![Version](https://img.shields.io/badge/version-3.1.0-blue?style=for-the-badge)](#)
[![Game](https://img.shields.io/badge/game-Tsunami%20Brainhort-red?style=for-the-badge)](#)
[![Framework](https://img.shields.io/badge/GUI-Rayfield-purple?style=for-the-badge)](#)
[![Author](https://img.shields.io/badge/author-ByteBandit__Ofici-orange?style=for-the-badge)](#)

> **A professional, feature-rich Roblox executor script for Tsunami Brainhort.**  
> Built with Rayfield UI · Multi-language · Optimized for zero lag

</div>

---

## 📋 Table of Contents

- [Requirements](#-requirements)
- [How to Use](#-how-to-use)
- [Key System](#-key-system)
- [Features](#-features)
  - [MOD GOD](#-mod-god)
  - [VIP FREE](#-vip-free)
  - [AUTO BRAINROT](#-auto-brainrot)
  - [TELEPORT BASE](#-teleport-base)
  - [SPEED](#-speed)
  - [Settings](#-settings)
- [Changelog](#-changelog)
- [FAQ](#-faq)

---

## ⚙ Requirements

| Requirement | Details |
|---|---|
| **Executor** | Any executor with HTTP Requests enabled (Synapse X, Delta, Fluxus, Wave, etc.) |
| **HTTP Requests** | Must be **enabled** in your executor settings to load Rayfield GUI |
| **Game** | [Tsunami Brainhort](https://www.roblox.com/games/) on Roblox |
| **Key** | Required — see [Key System](#-key-system) section below |

---

## 🚀 How to Use

1. Open your preferred Roblox executor
2. Make sure **HTTP Requests** are enabled
3. Join **Tsunami Brainhort** on Roblox
4. Paste the script below into your executor and execute it:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ByteBandit-Ofici/ScriptBrainrot/main/ScriptBrainrot.lua"))()
```

5. Enter your **key** when prompted
6. The **Script Brainrot** GUI will open automatically

---

## 🔑 Key System

> ⚠️ **Coming Soon** — A key system will be added in a future update to protect the script.

Once active, you will need to:

1. Click the **Get Key** button in the key prompt
2. Complete the verification on the key page
3. Copy your key and paste it into the input field
4. Press **Confirm** to unlock the GUI

Keys are **free** and can be obtained through the official link that will be shared here when the system launches.

---

## ✨ Features

### 🛡 MOD GOD

The most powerful moderation tab. Gives you full control over the game environment.

**Wave Management**

| Feature | Description |
|---|---|
| **Wave Delete Loop** | Toggles a continuous loop that deletes `Wave1_Visual` through `Wave50_Visual` every **1 second** automatically |
| **Delete All Waves Now** | Instantly performs a one-time sweep and removes all active wave visuals from the workspace |

> 💡 The wave loop uses `FindFirstChild` (direct lookup) instead of walking all descendants — this is what keeps it **lag-free**.

**Player Control**

| Feature | Description |
|---|---|
| **Auto-Kick on Join** | Automatically scans every player who joins the server and removes them if they carry the banned item ID |
| **Remove Cheater Players** | Manually scans all currently connected players and kicks anyone with the banned item |

The banned item is identified by its unique ID: `adde680a-9773-4436-900b-614e07fd8362`  
The script checks: item **Name**, item **Attributes** (`ItemId`, `AssetId`, `UUID`, etc.), and **CollectionService tags**.

---

### 👑 VIP FREE

Bypasses the VIP barrier in the game for free access to restricted areas.

| Feature | Description |
|---|---|
| **Remove VIP Walls** | Searches `Workspace` and `ReplicatedStorage` for the `VIPWalls` model and destroys it instantly |

---

### ⚡ AUTO BRAINROT

The core feature. Finds Brainrot objects in the game world, highlights them with ESP, and lets you teleport to them.

**How it works:**

1. Select a **rarity tier** from the dropdown
2. Press **Search for Brainrots**
3. The script scans the `ActiveBrainrots` folder → inside the selected rarity sub-folder
4. All found objects are highlighted with **color-coded ESP**
5. Press **Teleport to Random Brainrot** to warp to one instantly

**Rarity Tiers & ESP Colors**

| Rarity | Color |
|---|---|
| Common | ⬜ Gray |
| Uncommon | 🟩 Green |
| Rare | 🟦 Blue |
| Epic | 🟣 Purple |
| Legendary | 🟧 Orange |
| Mythical | 🟥 Red |
| Divine | 🟨 Gold |
| Celestial | 💛 Yellow |
| Cosmic | 🔵 Violet |
| Secret | 🟦 Cyan |
| Infinity | ⬜ White |

**ESP Controls**

| Feature | Description |
|---|---|
| **Show Name Labels** | Toggle floating name tags above highlighted Brainrots |
| **Refresh ESP** | Re-applies all highlights to the cached objects |
| **Clear ESP** | Removes all highlights and clears the object cache |

> 💡 ESP uses the `Highlight` instance (not `SelectionBox`) — it renders in a single GPU pass and has no per-frame surface recalculation cost.

---

### 🗺 TELEPORT BASE

Instantly warps you back to the ground/spawn area of the map.

| Feature | Description |
|---|---|
| **Teleport to Ground** | Searches the workspace for a ground part and teleports you on top of it |

**Search order:** `Ground` → `Baseplate` → `Base` → `SpawnPart` → `Map`

---

### 💨 SPEED

Enforces a custom WalkSpeed that the game **cannot reset**.

| Feature | Description |
|---|---|
| **Enable Speed Loop** | Starts a loop that reapplies your WalkSpeed every **0.2 seconds** |
| **WalkSpeed Slider** | Set any value from **16** (default) up to **500** |
| **Reset to Default** | Stops the loop and returns WalkSpeed to 16 immediately |

> **Why a loop?** Tsunami Brainhort resets your WalkSpeed constantly through game events. The 0.2s enforcement loop overwrites any reset the game applies — it runs faster than the game can reset you.

> **Respawn safe:** The loop automatically re-applies your speed after you die and respawn via a `CharacterAdded` hook.

---

### ⚙ Settings

Customize the script to your preference.

**Language**

| Language | Status |
|---|---|
| English | ✅ Fully supported |
| Portuguese | ✅ Fully supported |
| Spanish | ✅ Fully supported |

Language changes apply **instantly** — no script reload needed.

**Themes**

| Theme | Rayfield Name |
|---|---|
| Black (Default) | `Default` |
| Ocean Blue | `Ocean` |
| Emerald Green | `Green` |
| Rose / Amethyst | `Amethyst` |
| Light | `Light` |

Themes apply instantly via `Rayfield:SetTheme()`.

**Miscellaneous**
- **Reset Session Stats** — Clears all counters (waves destroyed, players kicked, teleports, searches)

---

## 📜 Changelog

### v3.1.0
- **ADD** — Speed tab with WalkSpeed slider (16–500) and 0.2s enforcement loop
- **ADD** — Auto speed recovery on character respawn via `CharacterAdded` hook

### v3.0.0
- **FIX** — Removed `BindToClose` (server-only API — was crashing the client with an error)
- **FIX** — Wave loop completely rewritten; no longer uses `GetDescendants()` which was causing severe lag
- **FIX** — Settings theme now correctly calls `Rayfield:SetTheme()` instead of just saving to state
- **FIX** — Language selector now applies changes immediately via live `T()` calls
- **ADD** — Teleport Base tab (searches for Ground / Baseplate / Base / SpawnPart)
- **OPT** — ESP switched from `SelectionBox` to `Highlight` instance (much lower render cost)
- **OPT** — Wave loop interval raised from 0.4s to 1.0s to keep client FPS stable

### v2.0.0
- Initial public release with MOD GOD, VIP FREE, AUTO BRAINROT, Credits, Settings

---

## ❓ FAQ

**Q: The script isn't loading — what do I do?**  
A: Make sure **HTTP Requests** are enabled in your executor. The script needs to download Rayfield from `sirius.menu`.

**Q: The waves aren't being deleted.**  
A: Enable the **Wave Delete Loop** toggle in the MOD GOD tab, or press **Delete All Waves Now** for a manual sweep.

**Q: Auto Brainrot isn't finding anything.**  
A: The `ActiveBrainrots` folder may be named differently in the current version of the game, or the rarity folder may be empty. Try a different rarity.

**Q: Speed isn't working after I respawn.**  
A: Make sure the **Enable Speed Loop** toggle is ON. The script will auto-reapply on respawn, but the toggle must be active.

**Q: The GUI theme didn't change.**  
A: Go to **Settings → Theme**, select your theme, and it should apply instantly. If not, re-execute the script.

**Q: Will there be more features?**  
A: Yes — the key system is coming soon, and more features are planned for future updates.

---

<div align="center">

**Script Brainrot** · by **ByteBandit_Ofici** · v3.1.0

*For Tsunami Brainhort — Roblox*

</div>
