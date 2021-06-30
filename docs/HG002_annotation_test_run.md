#### Preparing the output of variant calling pipeline to run annotation for HG002 vcf
* Set up the host instance using [these instructions](./Setting_up_host_instance.md) 
* Transfer and Create the appropriate directory for testing
```
$PROJECT_DIR/simulation/simulate_variant_calling_output.sh
```
* Start the annotation instance
```
NAME=annotation-1
${PROJECT_DIR}/create_instances/annotation_instance.sh \
	$NAME \
	${BUCKET}/sample.config
```
* Log into the instance and set PROJECT_DIR
```
gcloud beta compute ssh --zone "us-west1-a" $NAME --project "som-ashley-rapid-nicu-seq"
PROJECT_DIR=/data/urWGS
```
* Small variant call annotation
```
$PROJECT_DIR/annotation/process_pmdv_vcf.sh
```
* Structural variant call annotation
```
$PROJECT_DIR/annotation/download_data.sh
$PROJECT_DIR/annotation/process_sniffles_vcf.sh
```
