# JX1 UI engine notes — session detail (Aug 2026)

## File inventory (verified on <GAME_HOST_IP>, share root `VoLamTruyenKy`)

- `CLIENT/` = game dir: `game.exe`, `engine.dll`, `filtertext*.dll` (resolution hook), `dgVoodoo.conf` + `ddraw.dll`/`D3DImm.dll` (DirectDraw wrapper), `resolution.ini` (`[Resolution] Width=1600 Height=900 Log=0 PatchGameInit=1`), `config.ini` (`[Client] FullScreen=0 Theme=CTC`), `package.ini` (pak load order, `0=ui.pak`), `dllmain.cpp` (hook source, 3053 lines — reads `[Events]`/`[Smooth]` from fps_events.ini, GDI blit path).
- `CLIENT/ui/ctc/` = 164 .ini files, theme folder for `Theme=CTC`. Key: `顶部控制条.ini` (top bar: `[Life]`/`[Mana]`/`[Stamina]`/`[Exp]`/`[Level]`/`[WorldSort]`), `玩家头像.ini`, `公共.ini` (cursor list), `防沉迷进度条.ini` (vertical strip at right, PartType=3 vertical fill), `progressbar.ini`.
- `CLIENT/spr/Ui3/` + `CLIENT/spr/f3/` = loose sprites. Bar sprites in `spr/Ui3/主界面/` (`Ö÷½çÃæ`): `ÉúÃüÌõ.spr` (生命条, HP), `ÄÚÁ¦Ìõ.spr` (内力条, MP), `ÌåÁ¦Ìõ.spr`, `¾­ÑéÌõ.spr` — all 106x11, 2004 bytes. Also `ctc_1600.spr`, `-ctc_1600.spr`, `cuctc_1600.spr` (theme background variants).
- `TOOL/`: `ui1600/` (unpacked 1600 theme: `Spr/f3`, `Spr/Ui3`, `ui/ctc1024`), `ResolutionHook.0.0.2/`, `Unpack/` (unpack.exe CLI), `SPRViewer/` (.NET app), `UI+3/`, `VLTK_Launcher.rar`, `UI 3 + 6 Ô CTC (1024x768) (800x600)_pas_hoiquanvolam.zip`.

## Window/ini anatomy (顶部控制条.ini — top control bar)

```ini
[Main]                      ; window origin + bg image
Left=524  Top=0  Width=552  Height=17
Image=\Spr\Ui3\主界面\新血条面板.spr
Button0=Life  Button1=Mana  Button2=Stamina  Button3=Exp  Button4=Level  Button5=WorldSort

[Life]                      ; data-bound part — MOVES when Left/Top changed
Left=168  Top=3  Width=104  Height=14
Part=1  ClassType=Player_Life

[Life_Image]                ; child: the fill bar image
Left=0  Top=0  Width=104  Height=9
Image=\Spr\Ui3\主界面\生命条.spr  PartType=0   ; 0=horizontal fill, 1=vertical-ish variant

[Life_Text]                 ; child: value text
Left=0  Top=12  Width=104  Height=12  Font=12  HAlign=1  Color=255,255,255
```

Key insight: `[Life]` is hardcoded-bound via `ClassType=Player_Life` — that's why it relocated to corners fine. An unlisted section (e.g. `[BgLife]`) was silently ignored — engine doesn't instantiate it. UI+3 mod's toolbar shows the WORKING add-button pattern:

```ini
Button12=ItemEx  Button13=Task  Button14=ZhenFa
[ItemEx]
Left=300  Top=534  Width=28  Height=28  Trans=0
Image=\spr\Ui3\按钮条按钮\子母袋按钮.spr
Up=0  Down=1  Over=2  OverFrame=2
Tip=Túi hành trang  ClassType=Player_ItemEx
```

## Crash incident timeline (HP orb attempt)

1. Appended `[BgLife]`/`[BgMana]` sections with Image=frame_sel_avata.spr → **not rendered** (engine ignores undeclared sections). Even after adding `Button6/7` + CRLF fix + BMP files → still nothing (BMP not loadable by `Image=`).
2. Swapped `[Life_Image]` `Image=` → minimap `frame_all.spr` → rendered but wrong placement, not circular.
3. User replaced `ÉúÃüÌõ.spr` with tool-generated 230x230 sprite (fields 8-11 = 115,115) → **rendered as 2x2 sheet** (circles duplicated in a row) — game tolerated it.
4. I binary-patched fields 8-11 → 0,0 on that sheet-encoded file → **CRASH** (Access Violation at 00680F18/00680F60 — same stale address family as old logs). Lesson: pixel data is frame-encoded; header-only patch breaks frame math. Rollback = restore original spr; game fine again.
5. User made `hp.spr` (128x128, fields 64,64) → wired `[Life_Image]` to it → **CRASH again**. Same root: sheet-encoded data from user's converter tool.
6. Conclusion: correct path = re-pack source PNG as TRUE single frame (fields 0,0, total = frame) in the tool; do not binary-patch. Verify header before wiring into ini: total WxH + fields 8-11 must be (W,H,0,0).

## Filename byte map (GBK → UTF-8)

- `¶¥²¿¿ØÖÆÌõ.ini` → 顶部控制条.ini (top control bar)
- `ÉúÃüÌõ.spr` → 生命条.spr (HP bar); `ÄÚÁ¦Ìõ.spr` → 内力条.spr (MP bar)
- `Ö÷½çÃæ` → 主界面 (main interface folder); `¹¤¾ß¿ØÖÆÌõ.ini` → 工具控制条.ini; `Íæ¼ÒÐÅÏ¢Ö÷½çÃæ.ini` → 玩家信息主界面.ini
- Decoding recipe for listing output: bytes → decode utf-8 → encode latin-1 → decode gbk (see session; double-encoding path).

## Verification checks before/after every edit

- CRLF: `d.count(b'\r\n')` vs LF-only `d.count(b'\n') - d.count(b'\r\n')` must be 0.
- GBK path bytes in Python: build with `'主界面'.encode('gbk')`, never Chinese literals in bytes().
- Post-upload: download + `diff`; assert header of any new .spr before it goes in a running game.
