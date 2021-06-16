# Ultra-Rapid Whole Genome Sequencing pipeline

## Base calling and Alignment
### Software:
* `Guppy` v4.2.2 (Commercial software from Oxford Nanopore Technologies)
* `Minimap2` [v2.17-r974](https://github.com/lh3/minimap2/commit/2da649d1d724561d4c2bbe1be9123e2b61bc0029)
* `samtools` [v1.11](https://github.com/samtools/samtools/commit/d58fc8a16729f25407da6729c440a51140396f4c)

### Instance type:
* Custom N1 instance
* 48 vCPUs
* 200 GB RAM
* 4 x NVIDIA Tesla V100
* 3 x Local SSD Scratch Disk

## Small Variant Calling
### Software:
* `PEPPER` (Docker - kishwars/pepper_deepvariant:test-v0.5)
* `Margin` (Docker - kishwars/pepper_deepvariant:test-v0.5)
* `Google DeepVariant` (Docker)
  * `none` model (Docker - kishwars/pepper_deepvariant:test-v0.5)
  * `rows` model (Docker - kishwars/pepper_deepvariant:test-v0.5-rows)
* `samtools` [v1.11](https://github.com/samtools/samtools/commit/d58fc8a16729f25407da6729c440a51140396f4c)

### Instance type:
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 4 x NVIDIA Tesla P100
* 1 x Local SSD Scratch Disk

## Structural Variant Calling
### Software:
* `Sniffles` [v1.0.12](https://github.com/fritzsedlazeck/Sniffles/commit/0f9a068ecee84fff862c12e581693be273ccf89e)

### Instance type:
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 1 x Local SSD Scratch Disk

## Variant Call Annotation
### Software:
* `bctools` [v1.11](https://github.com/samtools/bcftools/commit/df43fd4781298e961efc951ba33fc4cdcc165a19)

### Instance type:
* Standard N1 instance
* 64 vCPUs
* 240 GB RAM
* 1 x Local SSD Scratch Disk
