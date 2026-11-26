# AudioReach Topology

Topology files for Qualcomm platforms that use the AudioReach audio
framework (the Qualcomm Audio Processing Manager, APM, and its DSP modules).

Topologies are written as m4 templates under per-SoC directories. The build
runs `m4` to expand each template into an [alsa-topology] `.conf` file, compiles
that with `alsatplg` into a binary `-tplg.bin` topology, and generates an HTML
diagram of the graph for review.

[alsa-topology]: https://github.com/alsa-project/alsa-utils/tree/master/topology

## Supported platforms

Each board or device has a `.m4` source in its SoC directory.

The complete list of targets, with their output paths, is in the `TPLGS` list in
[`CMakeLists.txt`](CMakeLists.txt).

## Repository layout

- `audioreach/` - AudioReach building blocks: the subgraph, container, and
  module macros (`module_*.m4`), and the device and stream subgraph templates
  (`subgraph-*.m4`, `stream-subgraph.m4`, `device-subgraph.m4`). `tokens.m4`
  defines the vendor token IDs.
- `util/` - Shared m4 helpers for PCM, mixer controls, and routes, plus
  `gen_topology_html.py`, which renders the topology HTML.
- `<soc>/` - Board-level templates. Each one includes the shared helpers and
  adds the DAI links, PCM streams, and controls for that board.
- `CMakeLists.txt` - Build rules and the list of topologies to build.
- `test.conf` - A standalone alsa-topology configuration fragment. It is not
  part of the CMake build.

## Requirements

- CMake 3.10 or newer
- `m4`
- `alsatplg` from [alsa-utils](https://github.com/alsa-project/alsa-utils)
- Python 3 (for the HTML generator; no third-party packages needed)

On Debian or Ubuntu:

```sh
sudo apt install cmake m4 alsa-utils python3
```

## Building

Configure and build all topologies out of tree:

```sh
cmake -B build
cmake --build build
```

The outputs go under `build/<vendor>/...`. For example:

```
build/qcom/sm8550/SM8550-HDK-tplg.bin
build/qcom/sm8550/SM8550-HDK.html
```

To build one topology, pass its target name, which is `topology_<output>`:

```sh
cmake --build build --target topology_SM8550-QRD
```

The `.html` file is a visual overview of the topology. Open it in a browser to
review the routing. It loads Mermaid.js from a CDN, so it needs network access.

You can also run the steps by hand for a single board:

```sh
m4 -I . -I build sm8550/SM8550-HDK.m4 > SM8550-HDK.conf
alsatplg -c SM8550-HDK.conf -o SM8550-HDK-tplg.bin
python3 util/gen_topology_html.py SM8550-HDK.conf SM8550-HDK.html
```

## Installing

Installation copies each `-tplg.bin` into `$FW_LOCATION/<vendor>/...`. The
`FW_LOCATION` environment variable is read at configure time, so set it when
you run CMake, then install:

```sh
FW_LOCATION=/lib/firmware cmake -B build
cmake --build build
cmake --install build
```

Pass `-DSYNCFW=ON` at configure time to skip the directories listed in
`SKIPSYNC` in `CMakeLists.txt`. This is useful when syncing with
`linux-firmware`, which does not yet have those files.

## Adding a new board

1. Create `<soc>/<BOARD>.m4` (or add to an existing SoC directory). Start from a
   similar board: include the `audioreach/` and `util/` helpers, then define the
   FE PCM streams, BE DAIs, and routes.
2. Add an entry to `TPLGS` in `CMakeLists.txt`, in the form
   `"<soc>/<input>\;<output-name>\;<vendor>/<path>\;"`. The output directory
   mirrors the firmware path in `linux-firmware`, such as
   `qcom/sm8550/<vendor>/<model>`.
3. If the topology is not yet in `linux-firmware`, add its output directory to
   `SKIPSYNC`.
4. Build it and open the generated HTML to check the graph.

## Continuous integration

GitHub Actions (`.github/workflows/ci.yml`) builds the whole project with
CMake on every push and pull request, and once a week. It installs `alsa-utils`
for `alsatplg`.

## License

Most files are licensed under the BSD-3-Clause license (see
[`LICENSE.BSD-3-Clause`](LICENSE.BSD-3-Clause)).

The CI workflow files are
under GPL-2.0 (see [`.github/workflows/LICENSE.GPL-2.0`](.github/workflows/LICENSE.GPL-2.0)).
