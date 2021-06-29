#### Preparing the output of Guppy and Minimap2 to test PEPPER-Margin-DeepVariant pipeline for a subset of chromosomes for HG002
* Set up the host instance using ./Setting_up_host_instance.md
* Transfer and Create the appropriate directory for testing
```
$PROJECT_DIR/simulation/simulate_alignment_output.sh
```
* Start 2 instances to run PEPPER-Margin-DeepVariant on chr2 and chr16,chr21
```
parallel -j 2 $PROJECT_DIR/create_instances/pmdv_instance.sh ::: \
	pmdv-{1..2} :::+ \
	chr2 \
	chr16:chr21 ::: \
	${BUCKET}/sample.config
```
