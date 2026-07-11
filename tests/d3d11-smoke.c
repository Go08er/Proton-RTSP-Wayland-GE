// SPDX-License-Identifier: BSD-3-Clause

#include <stdio.h>
#include <windows.h>
#include <d3d11.h>
#include <dxgi.h>

static void print_hresult(const char *label, HRESULT hr)
{
    printf("%s failed: 0x%08lx\n", label, (unsigned long)hr);
}

int main(void)
{
    static const D3D_FEATURE_LEVEL levels[] = {
        D3D_FEATURE_LEVEL_11_1,
        D3D_FEATURE_LEVEL_11_0,
        D3D_FEATURE_LEVEL_10_1,
        D3D_FEATURE_LEVEL_10_0,
    };

    ID3D11Device *device = NULL;
    ID3D11DeviceContext *context = NULL;
    D3D_FEATURE_LEVEL selected = 0;
    HRESULT hr;

    hr = D3D11CreateDevice(
        NULL,
        D3D_DRIVER_TYPE_HARDWARE,
        NULL,
        0,
        levels,
        sizeof(levels) / sizeof(levels[0]),
        D3D11_SDK_VERSION,
        &device,
        &selected,
        &context);

    if (FAILED(hr)) {
        print_hresult("D3D11CreateDevice", hr);
        return 1;
    }

    printf("D3D11CreateDevice ok, feature level 0x%04x\n", (unsigned int)selected);

    if (context)
        context->lpVtbl->Release(context);
    if (device)
        device->lpVtbl->Release(device);

    return 0;
}
