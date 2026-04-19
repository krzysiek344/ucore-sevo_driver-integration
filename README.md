# ucore - micro RISC-V core

## Repository cloning
```bash
git clone --recursive git@github.com:asicsagh/ucore.git
```

## Environment initialization
```bash
. env.sh
```

## Simulation execution
### Options
```
-c              console mode,
-l              list available tests,
-t <test_name>  execute test.
```

### Example
```bash
sim_runner.sh -ct core
```

## Bitstream generation
```bash
fpga_bitstream_generator.sh
```

## Serial port configuration
Baud rate: `92160`
