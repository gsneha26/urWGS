#### Preparing the output of variant calling pipeline to run annotation for HG002 vcf
* Set up the host instance using ./Setting_up_host_instance.md
* Transfer and Create the appropriate directory for testing
```
$PROJECT_DIR/simulation/simulate_alignment_output.sh
```
* Start the annotation instance
```
${PROJECT_DIR}/create_instances/annotation_instance.sh \
	annotation-1 \
	${BUCKET}/sample.config
```
