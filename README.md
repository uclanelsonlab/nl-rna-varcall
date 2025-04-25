# nl-rna-varcall
Variant calling pipeline for RNAseq aligned data

## Download reference files:
```bash
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/gencode43/GRCh38.p13/GRCh38.primary_assembly.genome.fa .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/gencode43/GRCh38.p13/GRCh38.primary_assembly.genome.fa.fai .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/gencode43/GRCh38.p13/GRCh38.primary_assembly.genome.fa.gz .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/gencode43/GRCh38.p13/GRCh38.primary_assembly.genome.dict .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/small_exac_common_3.hg38.vcf.gz .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/small_exac_common_3.hg38.vcf.gz.tbi .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/af-only-gnomad.hg38.vcf.gz .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/af-only-gnomad.hg38.vcf.gz.tbi .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/Homo_sapiens_assembly38.known_indels.vcf.gz .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/Homo_sapiens_assembly38.known_indels.vcf.gz.tbi .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.gz .
aws s3 cp s3://ucla-rare-diseases/UCLA-UDN/assets/reference/broad-references/hg38/v0/Homo_sapiens_assembly38.dbsnp138.vcf.gz.tbi .
```
> Remember to update the `nextflow.config` with the path of the files located in the machine you are running this pipeline.
- It is possible to find this files on [here](https://cloud.google.com/storage/docs/gsutil_install#linux)

## Create the `samplesheet.csv`
- Follow the format below:
```bash
sample,alignment,index
CDMD1601,/path/to/CDMD1601.hg38_rna.22.cram,/path/to/CDMD1601.hg38_rna.22.cram.crai
```
> Make sure the file is located in the machine you are running the pipeline.

## Run the pipeline
```bash
cd /path/to/nl-rna-varcall/
nextflow run main.nf --samplesheet /path/to/samplesheet.csv
```

## The outputs
- If you follow the previous command the outputs are located in `/path/to/nl-rna-varcall/results/`.

