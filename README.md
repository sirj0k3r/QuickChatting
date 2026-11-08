**QuickChat** is an addon that lets you choose which chat tab is selected when you log in or reload, instead of always starting on General.

* Pick any tab docked with General as your default
* Applies on login and `/reload`, not on zone changes or instance portals
* Saved per character

## Settings
* **Default Chat Tab**
    * Lists the tabs docked with General, in dock order
    * **General** is the default: the addon does nothing and the game behaves as usual

## How it works
* The choice is stored by tab name and position. If you move the tab, it is still found by name.
* If the chosen tab is renamed, deleted or undocked, General is used and the settings panel shows a notice. The saved choice is kept, so the tab is picked up again if it comes back.
* Whisper and other temporary tabs are not listed.
* The tab is selected right after login, and checked once more a second later in case the game switched back to General. If you have already clicked another tab by then, it is left alone.
* Picking a tab in the settings panel switches to it immediately.

## Options
Esc > Options > AddOns > Quick Chat, or type `/quickchat` or `/qchat`.
