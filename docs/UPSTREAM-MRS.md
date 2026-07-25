# Upstream merge-request map

These four topic branches split the carried changes into reviewable commits based on RTSP commit `3b4a5f4`. Subjects follow the surrounding upstream `<area>: <imperative>` style.

## MR 1 — Native Wayland build and launcher wiring

- **branch:** `feat/wayland-build-wiring`
- **subject:** `proton: Enable native Wayland sessions`
- **depends on:** none
- **attribution:** project maintainer
- **external prerequisite:** the upstream Wine gitlink must contain the native-Wayland driver before this wiring can produce a usable Wayland build.

**Commit body:**

Native Wayland needs its keyboard, protocol, locale, and monitor-selection inputs available inside the Proton distribution rather than supplied accidentally by the host. Selecting the driver in the launcher keeps the native-Wayland environment coherent while preserving the existing X11 path when the option is absent.

**Source mapping:**

- `patches/proton-rtsp-wayland.patch` → `.gitmodules`
  - `@@ -75,3 +75,13 @@`: register the `libxml2`, `libxkbcommon`, and `wayland-protocols` source locations.
- `patches/proton-rtsp-wayland.patch` → `Makefile.in`
  - `@@ -169,6 +170,52 @@`: add the libxml2, libxkbcommon, and Wayland Protocols Meson rules.
  - `@@ -616,6 +663,7 @@ WINE_SOURCE_ARGS = \`: pass `--with-wayland` to Wine.
  - `@@ -633,7 +681,7 @@ WINE_x86_64_AUTOCONF_ARGS += \`: make Wine depend on the packaged libxml2 and libxkbcommon builds.
  - `@@ -1299,6 +1350,76 @@ all-dist: $(OBJ)/.icu-aarch64-dist`: package X11 locale data and the pinned xrandr helper.
- `patches/proton-rtsp-wayland.patch` → `proton`
  - `@@ -529,6 +533,7 @@ class Proton:`: locate the packaged xrandr helper for the normal host architecture.
  - `@@ -541,6 +546,7 @@ class Proton:`: locate the packaged xrandr helper for AArch64.
  - `@@ -1461,6 +1467,7 @@ class Session:`: carry that helper into each session.
  - `@@ -1569,6 +1576,28 @@ class Session:`: discover the primary monitor from packaged xrandr output.
  - `@@ -1705,6 +1747,8 @@ class Session:`: map `PROTON_ENABLE_WAYLAND` and `PROTON_USE_WAYLAND` to the `wayland` compatibility option.
  - `@@ -1892,6 +1936,33 @@ class Session:`: select `winewayland.drv`, set the monitor and locale environment, disable the X11 driver, and normalize input-related state for a native-Wayland session.
- `patches/proton-alpha2.patch` → `proton`
  - `@@ -1947,19 +1947,19 @@ class Session:`: retain explicit `WINE_MOVE_HACK` and `PROTON_NO_STEAMINPUT` values, clear virtual-controller state whenever Steam Input is disabled, and set the packaged locale path without replacing an explicit value.

## MR 2 — Explicit XRizer launcher mode

- **branch:** `feat/xr-mode-launcher`
- **subject:** `proton: Add an explicit XRizer mode`
- **depends on:** none
- **attribution:** project maintainer

**Commit body:**

XRizer implements the Windows OpenVR API over the host OpenXR runtime, so initializing Proton's Windows OpenXR bridge at the same time can make both paths compete for the same runtime during graphics-device creation. An explicit opt-in disables `wineopenxr` only for XRizer while leaving the existing automatic behavior unchanged for SteamVR, OpenComposite, and Windows OpenXR applications.

**Source mapping:**

- `patches/proton-rtsp-wayland.patch` → `proton`
  - `@@ -1665,6 +1694,19 @@ class Session:`: parse and validate `PROTON_XR_MODE`, then apply `wineopenxr=d` only for the `xrizer` mode.
  - `@@ -1912,6 +1983,7 @@ class Session:`: record the selected XR mode in a Proton log.

## MR 3 — WineOpenXR decoupling on the RTSP build

- **branch:** `feat/wineopenxr-decouple`
- **subject:** `wineopenxr: Decouple XR and VR registry state`
- **depends on:** none
- **attribution:** Proton-GE commit `20ce609c432d3cc5e6c6051680ee1a75e0930782`, carried unchanged at GE snapshot `a5c30efa111c6a834395e70da88c801536c68f6d`; RTSP makedep adapter by the project maintainer

**Commit body:**

OpenXR applications launched outside Steam need the XR registry cache and Vulkan callback state to initialize without relying on vrclient having populated the OpenVR path first. Keeping the caches distinct also avoids treating OpenXR and OpenVR lifecycle state as interchangeable, while the one-line RTSP adapter preserves this tree's existing makedep-provided loader linkage.

**Proton-GE source mapping:**

- `patches/wineopenxr-decouple-a5c30efa.patch` → `Makefile.in`
  - `@@ -1,6 +1,7 @@`: add the direct OpenXR loader link used by Proton-GE. This line is canceled by the RTSP adapter below and is not present in the proposed commit's final tree.
- `patches/wineopenxr-decouple-a5c30efa.patch` → `openxr.c`
  - `@@ -4,6 +4,8 @@`
  - `@@ -17,6 +19,50 @@`
  - `@@ -39,6 +85,7 @@ XrResult WINAPI wine_xrCreateInstance`
  - `@@ -77,7 +124,9 @@ XrResult WINAPI wine_xrCreateInstance`
  - `@@ -148,10 +197,13 @@ XrResult WINAPI wine_xrEnumerateInstanceExtensionProperties`
  - `@@ -177,7 +229,6 @@ XrResult WINAPI wine_xrEnumerateInstanceExtensionProperties`
  - `@@ -223,7 +274,7 @@ XrResult WINAPI wine_xrGetVulkanGraphicsDeviceKHR`
  - `@@ -237,7 +288,7 @@ XrResult WINAPI wine_xrGetVulkanGraphicsDevice2KHR`
  - `@@ -264,7 +315,7 @@ XrResult WINAPI wine_xrGetVulkanInstanceExtensionsKHR`
  - `@@ -301,16 +352,18 @@ static VkResult WINAPI vk_create_instance_callback`
  - `@@ -331,7 +384,7 @@ static VkResult WINAPI vk_create_instance_callback`
  - `@@ -344,24 +397,30 @@ static VkResult WINAPI vk_create_device_callback`
  - `@@ -460,6 +519,7 @@ NTSTATUS is_available_instance_function_openxr`
  - `@@ -470,6 +530,8 @@ NTSTATUS is_available_instance_function_openxr`
- `patches/wineopenxr-decouple-a5c30efa.patch` → `openxr_loader.c`
  - `@@ -1,7 +1,14 @@`
  - `@@ -9,10 +16,141 @@`
  - `@@ -110,11 +248,39 @@ static BOOL get_vulkan_extensions`
  - `@@ -161,9 +327,17 @@ static BOOL get_vulkan_extensions`
  - `@@ -196,6 +370,8 @@ done:`
  - `@@ -222,6 +398,8 @@ static XrResult wine_openxr_init_once`
  - `@@ -464,6 +642,11 @@ XrResult WINAPI xrCreateInstance`
  - `@@ -1763,6 +1946,7 @@ XrResult WINAPI xrCreateVulkanInstanceKHR`
  - `@@ -1775,6 +1959,7 @@ XrResult WINAPI xrCreateVulkanInstanceKHR`
  - `@@ -1782,6 +1967,7 @@ XrResult WINAPI xrCreateVulkanInstanceKHR`
  - `@@ -1978,8 +2164,14 @@ BOOL CDECL wineopenxr_init_registry`
  - `@@ -2000,9 +2192,83 @@ BOOL CDECL wineopenxr_init_registry`
- `patches/wineopenxr-decouple-a5c30efa.patch` → `openxr_loader.h`
  - `@@ -52,6 +52,7 @@ struct is_available_instance_function_openxr_params`
- `patches/wineopenxr-decouple-a5c30efa.patch` → `wineopenxr.spec`
  - `@@ -3,3 +3,5 @@`: export the private registration entry points.

**RTSP adapter source mapping:**

- `patches/wineopenxr-rtsp-makedep-integration.patch` → `wineopenxr/Makefile.in`
  - `@@ -1,7 +1,6 @@`: remove the GE patch's direct `-lopenxr_loader` assignment because RTSP's top-level `WINEOPENXR_LDFLAGS` and makedep wrapper provide the loader and `ntdll.so`.

## MR 4 — Immutable piper-phonemize input

- **branch:** `feat/piper-phonemize-pin`
- **subject:** `piper: Pin the piper-phonemize source archive`
- **depends on:** none
- **attribution:** project maintainer

**Commit body:**

A mutable branch archive can change without any corresponding Piper source change, making a later build consume different code under the same URL. Pinning the commit archive and its digest makes the external input reproducible and fails closed if the retrieved bytes differ.

**Source mapping:**

- `patches/piper-phonemize-pin.patch` → `piper/CMakeLists.txt`
  - `@@ -65,7 +65,8 @@ if(NOT DEFINED PIPER_PHONEMIZE_DIR)`: replace the mutable `pic` branch archive with commit `5ecbb9b59abcffe03a9775ae82491c9ac5037f4d` and SHA-256 `cd89aff6c3728776ffbf382bd6574876cc67d13402140fc5e3ec8c2bc813335f`.

## LOCAL-ONLY

The following hunks belong to this distribution's build, release, or diagnostic layer and should not be included in the four upstream merge requests:

- **Nix-oriented shell lookup and local job budgeting**
  - `patches/proton-rtsp-wayland.patch` → `Makefile.in`, `@@ -13,7 +13,7 @@`: use `bash` from `PATH`.
  - `patches/proton-rtsp-wayland.patch` → `Makefile.in`, `@@ -125,6 +125,7 @@ all-dist: | $(DST_DIR)`: derive `NINJA_JOBS` from the local Make budget.
  - `patches/proton-rtsp-wayland.patch` → `configure.sh`, `@@ -1,4 +1,4 @@`: use the environment-selected Bash.
  - `patches/proton-rtsp-wayland.patch` → `make/rules-meson.mk`, `@@ -61,7 +61,7 @@`: pass the local nested-job budget to Ninja.
- **Distribution input verification**
  - `patches/proton-rtsp-wayland.patch` → `Makefile.in`, `@@ -1239,9 +1287,10 @@`: record this distribution's Xalia archive digest.
  - `patches/proton-rtsp-wayland.patch` → `Makefile.in`, `@@ -1249,4 +1298,5 @@`: verify the downloaded Xalia archive.
  - `patches/proton-rtsp-wayland.patch` → `Makefile.in`, `@@ -1253,10 +1303,11 @@`: recheck the cached Xalia archive before extraction.
  - `patches/proton-alpha2.patch` → `Makefile.in`, `@@ -413,6 +413,12 @@`: remove the local Cargo cache path from GStreamer Rust artifacts.
- **Installed-tool and prerelease bookkeeping**
  - `patches/proton-rtsp-wayland.patch` → `proton`, `@@ -18,6 +18,10 @@`: suppress Python bytecode caches in the installed compatibility-tool directory.
  - `patches/proton-alpha2.patch` → `proton`, `@@ -45,7 +45,7 @@`: bump this fork's prefix version from `11.0-100` to `11.0-101`.
  - The `Proton-RTSP-Wayland-GE` display name, Alpha release labels, and archive identity are generated outside these four patches and remain distribution-only.
- **Local diagnostics**
  - `patches/proton-rtsp-wayland.patch` → `proton`, `@@ -2003,6 +2075,10 @@ class Session:`: log the fully assembled `WINEDLLOVERRIDES` value.
