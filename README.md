# Something from the Past

A Quest for Desert Ranger Armour

Merged NCR Veteran Ranger armor for Fallout 4, with the Ranger Helmet Enhanced
light system, independent visor tint and light slots, ballistic weave, and a
courier's letter hunt across the Commonwealth.

## Install

1. Install [Tactical Night Vision](https://www.nexusmods.com/fallout4/mods/58710).
   It is a master and must load before this plugin.
2. Keep the asset archives from
   [NCR Veteran Ranger - Redux](https://www.nexusmods.com/fallout4/mods/92572)
   and [Ranger Helmet Enhanced](https://www.nexusmods.com/fallout4/mods/41629).
   Do **not** enable their plugins.
3. Keep those original asset BA2 archives registered in `Fallout4Custom.ini`.
   This merge does not bundle or replace them.
4. Install the release with your mod manager, or extract it into your Fallout 4
   game directory so its top-level `Data` folder merges with the game's `Data`
   folder. Do not extract into `Data` itself and create a nested `Data/Data`.
5. Load `Tactical Night Vision.esp` before
   `fallchildrens_ncr_armor_redux.esp`.

The release contains these two runtime files:

```text
Data/
  fallchildrens_ncr_armor_redux.esp
  fallchildrens_ncr_armor_redux - Main.ba2
```

The plugin-named Main BA2 contains our compiled quest script. It is intended to
load automatically with the enabled ESP; it needs no separate INI registration.
The original armor archives still need the registration described above because
their own plugins are disabled. No third-party meshes or textures are repackaged.

### Upgrade from a loose-script/test build

Back up your save and previous mod files. Replace this mod's ESP and Main BA2.
Remove or disable the previous loose `Scripts/fcNCR_HandMeDown.pex` from this mod
(including any mod-manager override), because a loose script can override the
archived version. Do not remove scripts or archives belonging to other mods.
Restart Fallout 4 before loading the save. No uninstall, quest reset or clean
save is intended or required for this upgrade.

The script name, quest/form identities and saved placement variables are
preserved. Already-retained objects are not automatically moved; already-collected
items are not intentionally replaced. The main completion reward is guarded
against repeats. Letters already recorded on an existing save do not award
retroactive discovery XP.

## The hunt

The first letter is on the built-in kitchen counter in the Sole Survivor's house.
The armor and helmet are on the Natick Banks hillside dryer; the log is on the
changing table, with a shovel on the floor beside the machines. The script places
these as loose objects and preserves retained references on existing saves.

The trail can be joined at any letter. Each find points onward; earlier letters
are optional and do not force backtracking. Finding the equipment or log directly
also progresses the quest. Collecting the coat and log completes it and awards
100 XP once; the helmet is optional for completion. Each of the seven letters
awards 10 XP on its first recorded pickup and appears as a completed journal
entry, even if found out of order or after completion. Earlier finds do not
redirect the current breadcrumb.

## Location compatibility

The letter hunt and Natick scene require the vanilla layouts of these locations:

- The Sole Survivor's house kitchen in Sanctuary Hills.
- The workshop benches at Abernathy Farm and Graygarden.
- The upstairs room where you meet Preston and the settlers in the Museum of Freedom.
- The office desk inside Cambridge Police Station.
- The rented room in the Dugout Inn, Diamond City.
- The counter inside Fort Hagen Filling Station.
- The Natick Banks hillside house containing the dryer and changing table.

**Location overhauls that rebuild these areas or remove, replace, or move the
placement surfaces are not supported and may prevent the hunt from working.**
Use the vanilla layouts or a dedicated compatibility patch. Ordinary settlement
building is not inherently incompatible, but player-built objects can cover or
block access to the letters.

Scripted placement avoids cell/worldspace overrides; it does **not** guarantee
compatibility with redesigned locations. Items may be hidden inside altered
scenery, lack a supporting surface, or fail to appear if a required reference has
been removed. Changing load order alone will not reliably fix these conflicts.
Mods that only add distant territory or separate worldspaces are not inherently
incompatible.

## Build and package

`Data/fallchildrens_ncr_armor_redux.esp` is the canonical, complete prebuilt plugin.
`scripts/fcNCR_HandMeDown.psl` is the complete script source, including runtime
placement logic. Neither depends on the experimental ESP builders. Internal
`pilot_*` names are retained for compatibility with existing saved references.

`diary/*.md` holds the readable text sources. **Packaging does not edit the ESP.**
If diary text changes, update the prebuilt BOOK/TERM records separately and
verify their contents before packaging.

Requires `git`, `make`, Python 3, `curl`, and `7z`.
[fo4tools](https://github.com/fallchildren/fo4tools) is pinned as a submodule at
`third_party/fo4tools` (override with `FO4TOOLS_ROOT=/path/to/fo4tools` if needed).
Clone with `--recurse-submodules`, or let the Makefile initialize the pinned
F4SE and fo4tools submodules. Papyrus headers are generated in `build/headers/`. It uses
`../jezebel/bin/jezebel` when present, otherwise downloads the pinned Jezebel
release. Override `JEZEBEL=/path/to/jezebel` or `HEADERS=...` when appropriate.

```sh
make                          # compile, archive, verify, package
make package                  # same release pipeline
make pex                      # compile the complete PSL only
make version                  # print tag-derived version
make package VERSION=1.1.0-rc1 # explicit candidate version; does not create a tag
```

Output:

```text
build/scripts/fcNCR_HandMeDown.pex
build/scripts/fcNCR_HandMeDown.psc
build/package/Data/fallchildrens_ncr_armor_redux.esp
build/package/Data/fallchildrens_ncr_armor_redux - Main.ba2
dist/somethingfromthepast-<version>.7z
```

The release includes only the ESP and Main BA2. Documentation stays in the
repository; no development builders, diagnostics reports, source files, checksum
files or third-party assets are bundled. The BA2 is GNRL version 1, not a texture/DX10 archive. Packaging
extracts its script and verifies it byte-for-byte against the compiler output,
then tests the final 7z. Source remains available in the repository.

Versions default to Git tags (without a leading `v`); untagged/dirty work is not
a final release. Only tag after in-game testing is complete, including loading
the packaged script with any older loose PEX disabled.

### Nexus upload workflow

`.github/workflows/release.yml` builds on numbered tags or a manual Actions run.
Recursive checkout provides the pinned submodules without a separate fo4tools
checkout or branch pull. The workflow packages and verifies the mod, and retains
the 7z as a workflow artifact. Configure the repository secret
`NEXUSMODS_API_KEY` to enable uploads to file ID `8446437` on mod ID
`4943507469474`.

For a pre-publication API test, run the workflow manually with
`upload_to_nexus` enabled and a test version (blank generates
`1.1.0-test.<run number>`). This uploads a new version of the existing Nexus file;
it is not a dry run. Manual uploads do not archive the existing version, change
the mod version or make the upload the primary mod-manager download. The workflow
has no mod-page publishing step. Check the page remains unpublished afterward.
Without the checkbox, a manual run only builds and retains the artifact.

Numbered tag pushes also upload, update the mod version and select the primary
download, matching the Muffled Helmets release flow. Ensure the fo4tools commit
referenced by the submodule is pushed before running the workflow. GitHub requires a manual-dispatch
workflow to exist on the default branch before it appears in Actions.

## Credits and distribution

Built on assets by [Killusionary](https://www.nexusmods.com/fallout4/users/167456933)
and [JohnnyBlade](https://www.nexusmods.com/fallout4/users/2980268).
Personal merge; not redistributed. Building a personal archive does not grant
permission to redistribute the original authors' assets.
