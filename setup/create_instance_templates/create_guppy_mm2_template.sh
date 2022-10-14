gcloud compute instances create guppy-mm2-test \
  --zone us-central1-c \
  --machine-type=a2-highgpu-4g \
  --maintenance-policy=TERMINATE \
  --service-account=369092570559-compute@developer.gserviceaccount.com \
  --accelerator=count=4,type=nvidia-tesla-a100 \
  --tags=http-server,https-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=guppy-mm2-test,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20220927,mode=rw,size=100,type=projects/som-ashley-rapid-nicu-seq-dev/zones/us-central1-c/diskTypes/pd-balanced
