# Reporting problems

When reporting a problem, include:

- the selected Proton tool version;
- the exact launch options;
- whether XWayland or native Wayland was used;
- the game API: OpenVR, OpenXR, D3D11, D3D12, or Vulkan;
- the XR bridge and native runtime, if applicable;
- whether the problem also occurs in the default `auto` XR mode;
- a minimal, sanitized log excerpt surrounding the first relevant error.

### Sanitize logs before sharing

Proton, Wine, Vulkan, Steam, and OpenXR logs can expose personal or security-sensitive data. Never publish a raw log without reviewing it. Remove or replace:

- user names, host names, and absolute home-directory paths;
- account, profile, session, lobby, or device identifiers;
- IP addresses, local network names, headset serial numbers, and hardware UUIDs;
- authentication tokens, cookies, URLs containing secrets, and full command lines;
- environment variables and registry values unrelated to the report.

Do not upload an entire compatdata prefix, registry export, home directory, or environment dump. Automated redaction is not sufficient by itself; inspect the final file manually.
