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

- Reference samples you can use to validate it:
```bash
# DNA sample
s3 cp s3://gatk-test-data/rna_bam/NA12878_b37/NA12878.bam
s3://gatk-test-data/rna_bam/NA12878_b37/NA12878.bam.bai

# Reference:
s3://broad-references/hg19/v0/human_g1k_v37_decoy.fasta
s3://broad-references/hg19/v0/human_g1k_v37_decoy.fasta.fai
s3://broad-references/hg19/v0/human_g1k_v37_decoy.dict
s3://broad-references/hg19/v0/Homo_sapiens_assembly19.dbsnp138.vcf
s3://broad-references/hg19/v0/Homo_sapiens_assembly19.dbsnp138.vcf.idx
s3://broad-references/hg19/v0/Homo_sapiens_assembly19.known_indels_20120518.vcf
s3://broad-references/hg19/v0/Homo_sapiens_assembly19.known_indels_20120518.vcf.idx
s3://broad-references/hg19/v0/Mills_and_1000G_gold_standard.indels.b37.vcf.gz
s3://broad-references/hg19/v0/Mills_and_1000G_gold_standard.indels.b37.vcf.gz.tbi
```
