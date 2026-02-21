# budsAuction

**budsAuction** is a World of Warcraft (Patch 3.3.5a) addon for private servers (specifically [Ascension.gg](https://ascension.gg/)). It's a lightweight "Quick-Access" list addon that seamlessly attaches to the standard Blizzard Auction House, giving you fast access to your most frequently searched items.

## Features

- **Seamless Integration:** Automatically attaches to the Auction House window when you visit an auctioneer and closes together with the Auction House.
- **Freely Positionable & Resizable:** The window can be detached from the Auction House via an "Unlock" icon, moved freely around the screen, and resized to fit your needs.
- **Quick Search (1-Click):** A simple `CTRL + Left Click` on an item in your list inserts it directly into the Auction House search field and immediately starts the search.
- **Inventory Integration:** `CTRL + Left Click` on an item in your bags conveniently adds it directly to your budsAuction list.
- **Autocomplete:** When typing an item name into the budsAuction search field, the addon scans your inventory and automatically suggests matching items.
- **Account-wide Storage:** Your personal item list is saved across sessions and account-wide.
- **Customizable:** Adjust the item limit to preserve client performance, and customize the font size in the standard WoW Interface Options (`/budsauction` or `/ba`).

## Installation

1. Download the latest release from the [Releases page](https://github.com/Budtender3000/budsAuction/releases) or clone the repository.
2. Ensure the folder is named exactly **`budsAuction`**.
3. Move the folder to your WoW directory: `World of Warcraft/Interface/AddOns/budsAuction`.
4. Start World of Warcraft.
5. Enable the addon in the character selection screen (ensure "Load out of date AddOns" is checked, if necessary).

## Usage

1. Go to any **Auctioneer** in a capital city.
2. Open the Auction House. The **budsAuction** window will appear automatically.
3. **Add Items:**
   - Type a name into the input field (with autocomplete from your bags) and click Save.
   - *Or:* Use `CTRL + Left Click` on an item in your backpack while the Auction House is open.
4. **Search Items:** Use `CTRL + Left Click` on an entry in your budsAuction list to have the normal Auction House search for it.
5. You can adjust the item limit and font size in the Interface Options (`/budsauction`, `/ba`, or via the gear icon on the addon).

## Chat Commands (Slash Commands)

- `/budsauction`
- `/ba`
> Directly opens the Interface Options menu for budsAuction.

## Development & Compatibility

- **Patch:** Developed for WotLK 3.3.5 / 3.3.5a
- **Server:** Tested and designed for [Project Ascension](https://ascension.gg/) (Realm: Bronzebeard) and the [Ascension DB](https://db.ascension.gg/).
- **Dependencies:** None. The addon works completely standalone.
- **UI Design:** Uses native WoW Standard UI elements. Item IDs and Icons are retrieved directly via the WoW API (`GetItemInfo` / `GetItemIcon`).
- Fits into the **Budtender Universe** alongside [budsUI](https://github.com/Budtender3000/budsUI).

## Credits & License

**Budtender3000**

This project is licensed under the MIT License.

---
*Part of the Budtender Universe.*
