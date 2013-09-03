# nrf51822-linux-template

This project aims to be a template for building applications in a Linux environment
using the nRF51822 chip from Nordic Semiconductors.

## Dependencies

### GNU Tools for ARM Embedded Processors

You can download it from [here](https://launchpad.net/gcc-arm-embedded). If you
are using a system with `apt-get`, there is a PPA
[here](https://launchpad.net/~terry.guo/+archive/gcc-arm-embedded).

### J-Link v474

You can download the linux version from
[here](http://www.segger.com/jlink-software.html). You'll need to provide a
original serial key to access the files.

This project was tested using version `474`. It may not work against
other versions.

### nRF51822 SDK v4.3.0.27417

You can download it from
[here](http://www.nordicsemi.com/eng/Products/Bluetooth-R-low-energy/nRF51822).
You'll need to provide a original serial key to access the files.

The file is a Windows executable file. But you can use wine to install it.

This project was tested using version `4.3.0.27417`. It may not work against
other versions.

## Configuration

The `Makefile` contains the general build process and should be generic. You
need to edit `Makefile.project` to add project specific configuration. The
current `Makefile.project` contains configuration to build an example blink
application (implemented by `src/main.c`).

These are the variables you can put inside `Makefile.project`:

#### NRF51_SDK_PATH

Full path to Nordic nRF51 SDK. This variable should contains to the root of
the SDK.

#### JLINK_PATH

Full path to JLINK software.

#### SOC

Specify the current SoC. Possible values are defined in `nrf.h`.

####SOC_VARIANT

Specify the variant of the SoC. Possible values are `xxaa` (256 kb) and `xxab`
(128 kb).

#### BOARD

Specify the board. Possible values are defined in `boards.h`.

#### USE_SOFTDEVICE

Specify if the Soft Device is going to be used or not. Possible values are
`s110` and `blank`.

#### NRF51_SOFTDEVICE

Path to the `hex` file containing the softdevice.

#### PROJECT_TARGET

Specify the name of the build target.

### Other variables

* PROJECT_CFLAGS
* PROJECT_LDFLAGS
* PROJECT_INCLUDE_PATHS
* PROJECT_C_SOURCE_PATHS
* PROJECT_C_SOURCE_FILES
* PROJECT_ASM_SOURCE_PATHS
* PROJECT_ASM_SOURCE_FILES

## Build

The `Makefile` contains the following rules:

* `make` will build the firmware and put it inside `build` directory.
*`make clean` will erase the `build` directory.
* `make erase` will erase the firmware inside nRF51.
* `make install` or `make upload` will flash the firmware inside nRF51.
* `make softdevice` will flash the softdevice inside nRF51 (it will first erase the flash).
