# Ultra-Rapid whole genome nanopore sequencing pipeline

**Attn reviewers**: Detailed instructions for running PromethION simulation for a subset of the HG002 data and the associated base calling and alignment is provided [here](./docs/HG002_basecalling_alignment_test_run.md). Since Guppy is a commercially available software from Oxfor Nanopore Technologies, we have created anonymous Google Cloud Platform (GCP) user accounts with access to VM instance resources consisting of Guppy license to test the pipeline. Instructions to start using the GCP resources is available [here](./docs/GCP_instructions_reviewers.md). We have also added other demo instructions - [small variant calling](./docs/HG002_pmdv_test_run.md) using PEPPER-Margin-Deepvariant, [structural variant calling](./docs/HG002_sniffles_test_run.md)) using Sniffles, [annotation](./docs/HG002_annotation_test_run.md).

## Base calling and Alignment
### Software:
* Guppy v4.2.2 (Commercial software from Oxford Nanopore Technologies)
* Minimap2 [v2.17-r974](https://github.com/lh3/minimap2/commit/2da649d1d724561d4c2bbe1be9123e2b61bc0029)
* Utilities: samtools v1.11, CUDA v10.2, GNU parallel

### Instance type:
* Custom N1 instance
* 48 vCPUs
* 200 GB RAM
* 4 x NVIDIA Tesla V100
* 3 x Local SSD Scratch Disk
* Ubuntu 16.04 LTS

## Small Variant Calling
### Software:
* PEPPER v0.5 (Docker image - `kishwars/pepper_deepvariant:test-v0.5`)
* Margin (Docker image - `kishwars/pepper_deepvariant:test-v0.5`)
* Google DeepVariant
  * none model (Docker image - `kishwars/pepper_deepvariant:test-v0.5`)
  * rows model (Docker image - `kishwars/pepper_deepvariant:test-v0.5-rows`)
* Utilities: docker, samtools v1.11, bgzip v1.11, tabix v1.11, GNU parallel

### Instance type:
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 4 x NVIDIA Tesla P100
* 1 x Local SSD Scratch Disk
* Ubuntu 16.04 LTS

NOTE: [Parabricks DeepVariant](https://developer.nvidia.com/clara-parabricks) is commercially licensed and not available as a part of this repository for testing this pipeline.

## Structural Variant Calling
### Software:
* Sniffles [v1.0.12](https://github.com/fritzsedlazeck/Sniffles/commit/0f9a068ecee84fff862c12e581693be273ccf89e)
* Utilities: GNU parallel

### Instance type:
* Standard N1 instance
* 96 vCPUs
* 360 GB RAM
* 1 x Local SSD Scratch Disk
* Ubuntu 16.04 LTS

## Variant Call Annotation
### Software:
* SV Annotation (Docker image - `quay.io/jmonlong/svnicu:0.5`)
* Utilities: bctools v1.11, bedtools, tabix v1.11, bgzip v1.11, docker

### Instance type:
* Standard N1 instance
* 64 vCPUs
* 240 GB RAM
* 1 x Local SSD Scratch Disk
* Ubuntu 16.04 LTS


