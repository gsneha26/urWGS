### Setting up the instance templates

Generate the custom VM instance images using the following list of software and instructions provided [here](https://cloud.google.com/compute/docs/instance-templates/create-instance-templates). These will further be embedded with the instance templates with the configurations specified below for each stage of the pipeline using the instructions provided [here](https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images).

## a. Base calling and Alignment
### Softwarei (image name - `guppy-mm2-image-v1`):
* Guppy v4.2.2 (Commercial software from Oxford Nanopore Technologies)
* Minimap2 [v2.17-r974](https://github.com/lh3/minimap2/commit/2da649d1d724561d4c2bbe1be9123e2b61bc0029)
* Utilities: samtools v1.11, CUDA v10.2, GNU parallel

### Instance type (template name - `guppy-mm2-template`):
* Custom N1 instance
* 48 vCPUs
* 200 GB RAM
* 4 x NVIDIA Tesla V100
* 3 x Local SSD Scratch Disk
* Ubuntu 16.04 LTS

## b.1. Small Variant Calling
### Software (image name - `pmdv-image-v1`):
* PEPPER v0.5 (Docker image - `kishwars/pepper_deepvariant:test-v0.5`)
* Margin (Docker image - `kishwars/pepper_deepvariant:test-v0.5`)
* Google DeepVariant
  * none model (Docker image - `kishwars/pepper_deepvariant:test-v0.5`)
  * rows model (Docker image - `kishwars/pepper_deepvariant:test-v0.5-rows`)
* Utilities: docker, samtools v1.11, bgzip v1.11, tabix v1.11, GNU parallel

### Instance type (template name - `pmdv-template`):
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 4 x NVIDIA Tesla P100
* 1 x Local SSD Scratch Disk
* Ubuntu 16.04 LTS

NOTE: [Parabricks DeepVariant](https://developer.nvidia.com/clara-parabricks) is commercially licensed and not available as a part of this repository for testing this pipeline. Additionally, the final pipeline uses the Google DeepVariant (with rows model).

## b.2. Structural Variant Calling
### Software (image name - `sniffles-image-v1`):
* Sniffles [v1.0.12](https://github.com/fritzsedlazeck/Sniffles/commit/0f9a068ecee84fff862c12e581693be273ccf89e)
* Utilities: GNU parallel

### Instance type (template name - `sniffles-template`):
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 1 x Local SSD Scratch Disk
* Ubuntu 16.04 LTS

## c. Variant Call Annotation
### Software (image name - `annotation-image-v1`):
* SV Annotation (Docker image - `quay.io/jmonlong/svnicu:0.5`)
* Utilities: bctools v1.11, bedtools, tabix v1.11, bgzip v1.11, docker

### Instance type (template name - `annotation-template`):
* Standard N1 instance
* 64 vCPUs
* 240 GB RAM
* 1 x Local SSD Scratch Disk
* Ubuntu 16.04 LTS

