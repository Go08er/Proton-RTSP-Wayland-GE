<!-- SPDX-License-Identifier: BSD-3-Clause -->

# License bundle

This project and its release payload are multi-license. No single license
covers the complete Proton compatibility tool.

- `../LICENSE` is BSD-3-Clause and applies only to original project material.
- `../LICENSE.proton` is Valve's BSD-3-Clause license for top-level Proton
  material.
- `../LICENSE.upstream-proton` is Proton's original license-routing notice.
- `../LICENSE.wine` and `../COPYING.LIB.wine` cover Wine and the selected GE
  Wine patches under LGPL-2.1-or-later.
- `COMPONENTS.md` maps the principal redistributed components to their
  authoritative license and source material.
- Binary packaging generates `licenses/upstream/` by copying every LICENSE,
  COPYING, NOTICE, and Copyright file found in the exact prepared source tree.
- `licenses/manifest.sha256` authenticates the resulting notice bundle.

The project license does not relicense Proton, Wine, a GE patch, a model,
font, SDK-derived file, or any other third-party component. The original
upstream files remain authoritative if this summary and an upstream notice
ever disagree.
