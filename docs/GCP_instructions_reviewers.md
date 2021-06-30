### Google Cloud account and usage for the demonstrations

We have set up anonymous accounts for the purpose of the testing during the review especially since the Guppy software is proprietary. 

Accounts (Password)
1. nbt.reviewer.058e@gmail.com (LRFw7n73b!R@)
2. nbt.reviewer.544d@gmail.com (H#4^ytG$NjkI)
3. nbt.reviewer.767e@gmail.com (KOo&vYxpCOwd)

Instructions to start using the account:
* Login on the [Google Cloud Console](https://console.cloud.google.com/) with one of the email addresses above 
* Select the project - `som-ashley-rapid-nicu-seq`  

On the terminal (Ubuntu based instructions)
* Install Google Cloud SDK ([Instructions for a non-GCP instance](https://cloud.google.com/sdk/docs/install))
* Login with the above account
```
gcloud auth login
```
You will be redirected to a webpage/provided a link for the google login with the above account.
* To check the current settings/project in use
```
gcloud init
```

There is 1 demo test set provided for each stage -- guppy-minimap2, PEPPER-Margin-DeepVariant, Sniffles, Annotation. Every demo requires a host instance, the instructions for which are provided [here](./Setting_up_host_instance.md) 
