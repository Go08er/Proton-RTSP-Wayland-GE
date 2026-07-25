// SPDX-License-Identifier: BSD-3-Clause

#include <stdio.h>
#include <windows.h>
#include <d3d11.h>
#include <dxgi.h>

static void print_hresult(const char *label, HRESULT hr)
{
    printf("%s failed: 0x%08lx\n", label, (unsigned long)hr);
}

static LRESULT CALLBACK wndproc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
    (void)wparam;
    (void)lparam;

    if (msg == WM_CLOSE || msg == WM_DESTROY) {
        PostQuitMessage(0);
        return 0;
    }

    return DefWindowProcA(hwnd, msg, wparam, lparam);
}

int main(void)
{
    static const D3D_FEATURE_LEVEL levels[] = {
        D3D_FEATURE_LEVEL_11_1,
        D3D_FEATURE_LEVEL_11_0,
        D3D_FEATURE_LEVEL_10_1,
        D3D_FEATURE_LEVEL_10_0,
    };

    HINSTANCE instance = GetModuleHandleA(NULL);
    WNDCLASSA wc = {0};
    HWND hwnd;
    DXGI_SWAP_CHAIN_DESC desc = {0};
    IDXGISwapChain *swapchain = NULL;
    ID3D11Device *device = NULL;
    ID3D11DeviceContext *context = NULL;
    D3D_FEATURE_LEVEL selected = 0;
    HRESULT hr;

    wc.lpfnWndProc = wndproc;
    wc.hInstance = instance;
    wc.lpszClassName = "rtsp_wayland_swapchain_smoke";

    if (!RegisterClassA(&wc)) {
        printf("RegisterClassA failed: %lu\n", GetLastError());
        return 1;
    }

    hwnd = CreateWindowExA(
        0,
        wc.lpszClassName,
        "RTSP Wayland D3D11 Swapchain Smoke",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        640,
        360,
        NULL,
        NULL,
        instance,
        NULL);

    if (!hwnd) {
        printf("CreateWindowExA failed: %lu\n", GetLastError());
        return 1;
    }

    ShowWindow(hwnd, SW_SHOW);
    UpdateWindow(hwnd);

    desc.BufferDesc.Width = 640;
    desc.BufferDesc.Height = 360;
    desc.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    desc.SampleDesc.Count = 1;
    desc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    desc.BufferCount = 2;
    desc.OutputWindow = hwnd;
    desc.Windowed = TRUE;
    desc.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;

    hr = D3D11CreateDeviceAndSwapChain(
        NULL,
        D3D_DRIVER_TYPE_HARDWARE,
        NULL,
        0,
        levels,
        sizeof(levels) / sizeof(levels[0]),
        D3D11_SDK_VERSION,
        &desc,
        &swapchain,
        &device,
        &selected,
        &context);

    if (FAILED(hr)) {
        print_hresult("D3D11CreateDeviceAndSwapChain", hr);
        DestroyWindow(hwnd);
        return 1;
    }

    printf("D3D11CreateDeviceAndSwapChain ok, feature level 0x%04x\n", (unsigned int)selected);

    hr = swapchain->lpVtbl->Present(swapchain, 0, 0);
    if (FAILED(hr)) {
        print_hresult("IDXGISwapChain::Present", hr);
        swapchain->lpVtbl->Release(swapchain);
        context->lpVtbl->Release(context);
        device->lpVtbl->Release(device);
        DestroyWindow(hwnd);
        return 1;
    }

    printf("IDXGISwapChain::Present ok\n");

    swapchain->lpVtbl->Release(swapchain);
    context->lpVtbl->Release(context);
    device->lpVtbl->Release(device);
    DestroyWindow(hwnd);

    return 0;
}
