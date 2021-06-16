# Ultra-Rapid Whole Genome Sequencing pipeline

## Base calling and Alignment
### Software:
* Guppy v4.2.2 (Commercial software from Oxford Nanopore Technologies)
* Minimap2 v2.17-r974
* samtools v1.11

### Instance type:
* Custom N1 instance
* 48 vCPUs
* 200 GB RAM
* 4 x NVIDIA Tesla V100
* 3 x Local SSD Scratch Disk

## Small Variant Calling
### Software:
* PEPPER (Docker - kishwars/pepper_deepvariant:test-v0.5)
* Margin (Docker - kishwars/pepper_deepvariant:test-v0.5)
* Google DeepVariant (Docker)
  * none model (Docker - kishwars/pepper_deepvariant:test-v0.5)
  * rows model (Docker - kishwars/pepper_deepvariant:test-v0.5-rows)
* samtools v1.11

### Instance type:
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 4 x NVIDIA Tesla P100
* 1 x Local SSD Scratch Disk

## Structural Variant Calling
### Software:
* Sniffles v1.0.12

### Instance type:
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 1 x Local SSD Scratch Disk

## Variant Call Annotation
### Software:
* bctools v1.11

### Instance type:
* Standard N1 instance
* 64 vCPUs
* 240 GB RAM
* 1 x Local SSD Scratch Disk
