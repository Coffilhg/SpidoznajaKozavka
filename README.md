# SpidoznajaKozavka

Script Injection is only required for the PluginBigsettingsStoreService to work. This plugin does not read or write to your scripts, only to those it created itself in ServerStorage. You can check the source code, it's all here and build yourself if you want too!

1. Get the Plugin
    - **[Get it on Toolbox https://create.roblox.com/store/asset/70538529768465](<https://create.roblox.com/store/asset/70538529768465>)**
    - **[Download the rbxmx Here](<SpidoznajaKozavka.rbxmx>)** or [Here, if you prefer the one built using ``rojo build``, although Roblox Studio doesn't seem to recognize it](<SpidoznajaKozavkaRojoBuild.rbxmx>)
        > Put it into your Local Plugins Folder (e.g. `\Users\USER\AppData\Local\Roblox\Plugins` for Windows)
    - **Build Yourself (rokit required)**
        > ```
        > git clone https://github.com/Coffilhg/SpidoznajaKozavka
        > ```
        > 
        > ```
        > cd SpidoznajaKozavka
        > ```
        > 
        > ```
        > rokit install
        > ```
        > 
        > ```
        > wally install && rojo sourcemap default.project.json --output sourcemap.json && wally-package-types -s sourcemap.json Packages/
        > ```
        > 
        > ```
        > rojo serve default.project.json
        > ```
        > 
        > Open any place/experience in Roblox Studio
        > 
        > Open rojo plugin, connect
        > 
        > Click the SpidoznajaKozavka Folder in ServerScriptService with Right Mouse button
        > 
        > `Save / Export` -> `Save as Local Plugin`
        > 
        > Or, alternatively, run (although Roblox Studio doesn't seem to recognize it)
        > 
        > ```
        > rojo build default.project.json --output SpidoznajaKozavkaRojoBuild.rbxmx
        > ```
        > 
        > And put the output file into your Local Plugins Folder (e.g. `\Users\USER\AppData\Local\Roblox\Plugins` for Windows)
2. Write a Username or UserId to search for;
	> To enable autocomplete suggestions by **Display name** go to settings and allow/enable the corresponding setting.
	> 
	> Due to rate limits this will often fail the search, in which case you could just click the search button again.
3. Import the current avatar as R6 or R15 or load and select from available outfits.
	> If the target' *Inventory visibility* is not set to *Everyone*, you will only be able to import their current avatar.
	> 
	> Click again after selecting the avatar/outfit to auto-import it as it's inteded Rig Type (this only works if the RigType has completed loading).
	> 

---

You can modify the Plugin if needed, it's fairly simple to add more settings and change the HTTP request templates.

This plugin uses **roproxy** to access Roblox' OpenCloud API from Roblox;

**No HTTP requests (using the ``game:GetService(`HttpService`)``) are made unless the settings for the corresponding links are enabled, you're safe.**