# Booting Machines

Generate bootable images straight to the disk.

## Table of Contents

- [Raspberry Pi 5](#raspberry-pi-5)
- [Other Linux Devices](#other-linux-devices)
- [Post Image-Build](#post-image-build)
- [Todo](#todo)

> [!NOTE]
> **Pro Tipp**: When working in this repository  use `just` to run the build commands. This allows to skip the `build` section

## Raspberry Pi 5

For building and booting Raspberry Pi 5 images, refer to the important discussion here: [NixOS Issue #260754](https://github.com/NixOS/nixpkgs/issues/260754).

### Build
Run the following command to build the SD card image for Raspberry Pi 5:

```bash
nix --experimental-features 'nix-command flakes' build './boot/#nixosConfigurations.pi.config.system.build.sdImage'
```

## Other Linux Devices

For other Linux devices, such as physical servers, use the `raw-efi` format for UEFI-compatible bootable images.

### Build
Run the following command to build the bootable disk image:

```bash
nix --experimental-features 'nix-command flakes' build './boot/#diskImage'
```

This uses [nixos-generators](https://github.com/nix-community/nixos-generators) to produce the image in `raw-efi` format.

> [!WARNING]
> :red_circle: **IMPORTANT**: The Linux ISO that is built is currently **not tested**.

## Post Image-Build

To write the generated image to a disk, ensure `zstd` is available by running:

```bash
nix-shell -p zstd
```

Then copy the image to your disk with the following command:

For SD card images:
```bash
zstdcat result/nixos-sd-image-24.05.20241116.e8c38b7-aarch64-linux.img.zst | dd of=/dev/sdX status=progress
```

For raw or raw-efi images:
```bash
zstdcat result/disk-image.img.zst | dd of=/dev/sdX status=progress
```

Replace `/dev/sdX` with the appropriate disk or SD card device.

## Todo

- Integrate [disko-nix](https://github.com/nix-community/disko) for better disk partitioning and management.
