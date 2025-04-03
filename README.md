# nl-rna-varcall
Variant calling pipeline for RNAseq aligned data

- Zip file to create a pipeline on AWS HealthOmics:
```bash
git clone https://github.com/uclanelsonlab/nl-rna-varcall.git 
cd /path/to/nl-rna-varcall/

# fetch the awshealthomics branch
git fetch --all 
git checkout awshealthomics

zip -r nl-rna-varcall.zip *
```