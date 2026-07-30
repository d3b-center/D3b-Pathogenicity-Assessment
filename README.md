# Pathogenicity Preprocessing Workflow
This repo makes use of the git submodule feature for ease of code maintenance. To properly retrieve all relevant code:
```sh
git clone https://github.com/d3b-center/D3b-Pathogenicity-Preprocessing
git submodule init
git submodule update
```
## Prequisite
It is recommended to have first run the [Kids First Germline Annotation Workflow](https://github.com/kids-first/kf-annotation-tools/blob/v1.1.0/docs/GERMLINE_SNV_ANNOT_README.md).

## Pathogenicity Preprocessing Workflow
This workflow uses the prerequisite input to run the InterVar workflow and autoPVS1 tool.
The major pieces of software being used are:
 - ANNOVAR latest: The software has no versioning, but references do. See `annovar_db` section in [Recommended inputs](#recommended-inputs)
 - InterVar v2.2.1
 - AutoPVS1 v2.0.0: Modified from AutoPVS1 v2.0 to fit annotated KF vcf output. See [README for autoPVS1](https://github.com/d3b-center/D3b-autoPVS1/tree/v2.0.0#readme) for details

Optionally, if you wish to add and, if needed, overwrite another annotation from a VCF file (likely ClinVar), a BCFtools strip and annotate steps are provided. The input VCF will be processed, and its result will appear as an additional output in the workflow. 
### Recommended inputs:
 - `annovar_db`: ANNOVAR Database with at minimum required resources to InterVar. Need to use [ANNOVAR download commands](https://annovar.openbioinformatics.org/en/latest/user-guide/download/) to get the following:
     ```
        annovar_humandb_hg38_intervar/
        ├── hg38_AFR.sites.2015_08.txt
        ├── hg38_AFR.sites.2015_08.txt.idx
        ├── hg38_ALL.sites.2015_08.txt
        ├── hg38_ALL.sites.2015_08.txt.idx
        ├── hg38_AMR.sites.2015_08.txt
        ├── hg38_AMR.sites.2015_08.txt.idx
        ├── hg38_EAS.sites.2015_08.txt
        ├── hg38_EAS.sites.2015_08.txt.idx
        ├── hg38_EUR.sites.2015_08.txt
        ├── hg38_EUR.sites.2015_08.txt.idx
        ├── hg38_SAS.sites.2015_08.txt
        ├── hg38_SAS.sites.2015_08.txt.idx
        ├── hg38_avsnp147.txt
        ├── hg38_avsnp147.txt.idx
        ├── hg38_clinvar_20210501.txt
        ├── hg38_clinvar_20210501.txt.idx
        ├── hg38_dbnsfp42a.txt
        ├── hg38_dbnsfp42a.txt.idx
        ├── hg38_dbscsnv11.txt
        ├── hg38_dbscsnv11.txt.idx
        ├── hg38_ensGene.txt
        ├── hg38_ensGeneMrna.fa
        ├── hg38_esp6500siv2_all.txt
        ├── hg38_esp6500siv2_all.txt.idx
        ├── hg38_gnomad_genome.txt
        ├── hg38_gnomad_genome.txt.idx
        ├── hg38_kgXref.txt
        ├── hg38_knownGene.txt
        ├── hg38_knownGeneMrna.fa
        ├── hg38_refGene.txt
        ├── hg38_refGeneMrna.fa
        ├── hg38_refGeneVersion.txt
        ├── hg38_rmsk.txt
        └── hg38_seq
            ├── annovar_downdb.log
            └── hg38.fa
    ```
 - `intervar_db`: InterVar Database from git repo + mim_genes.txt
 - `autopvs1_db`: git repo files plus a user-provided fasta reference. For hg38, recommend:
    ```
    data/
        ├── Homo_sapiens_assembly38.fasta
        ├── Homo_sapiens_assembly38.fasta.fai
        ├── PVS1.level
        ├── clinvar_pathogenic_GRCh38.vcf
        ├── clinvar_trans_stats.tsv
        ├── exon_lof_popmax_hg38.bed
        ├── expert_curated_domains_hg38.bed
        ├── functional_domains_hg38.bed
        ├── hgnc.symbol.previous.tsv
        ├── mutational_hotspots_hg38.bed
        └── ncbiRefSeq_hg38.gpe
    ```
 - `annovar_db_str`: Name of dir created when `annovar_db` tar ball in decompressed. Default: `annovar_humandb_hg38_intervar`
 - `autopvs1_db_str`: Name of dir created when `autopvs1_db` tar ball in decompressed. Default: `data`
 - `intervar_db_str`: Name of dir created when `intervar_db_str` tar ball in decompressed. Default: `intervardb`
#### **Note:** We used a gene symbol liftover tool to allow gene symbols searches from different gene models to be found, `PVS1.level` was augmented with additional entries in which a gene symbols from the original file has changed.
The [update_gene_symbols.py](https://github.com/d3b-center/D3b-DGD-Collaboration/blob/v0.2.0/scripts/update_gene_symbols.py) tool was used to achieve this, with liftover source obtained from [here](https://ftp.ebi.ac.uk/pub/databases/genenames/hgnc/archive/monthly/tsv/hgnc_complete_set_2021-06-01.txt) to match gene symbols from default/recommended VEP annotation. Example command:
```sh
python3 /Users/brownm28/Documents/git_repos/D3b-DGD-Collaboration/scripts/update_gene_symbols.py -g hgnc_complete_set_2021-06-01.txt -f PVS1.level -z GENE level -u GENE -o results --explode_records 2> old_new.log
```
With `results` used to replace `PVS1.level` file. Recommend references for this workflow can be obtained [here](https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/files/#q?path=d3b_diskin_pathogenicity).

### InterVar Classification Workflow
This workflow is a critical component in generating scoring metrics needed to classify pathogenicity of variants.
Documentation for this can be found [here](docs/INTERVAR_WF.md)
### AutoPVS1
An additional pathogenicity scoring tool, run on the VEP-annotated input.
Documentation for this can be found [here](https://github.com/d3b-center/D3b-autoPVS1/tree/v2.0.0#readme)

### Optional Inputs
As mentioned above, the preprocessing workflow can add an additional annotation
 - `annotation_vcf`: hg38 chromosome-formatted VCF. If provided BCFtools will add annotation from the specified columns for each variant that matches
 - `bcftools_annot_columns`: A CSV string of from annotation to port into the input vcf. Must provide if `annotation_vcf` given. See [BCFtools annotate](https://samtools.github.io/bcftools/bcftools.html#annotate) documentation on how to properly reference
 - `bcftools_strip_for_vep`: If re-annotating certain `INFO` fields, it's best to strip the old annotation first to avoid conflicts. Use the same format as `bcftools_annot_columns` to reference fields being stripped
 - `bcftools_strip_for_annovar`: More of a convenience to strip the ANNOVAR VCF of annotations that maybe have been used initially in the workflow, but will likely not be used downstream 
 #### A note on ClinVar annotation
 For the publication, [ClinVar release 20231028](https://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/archive_2.0/2023/clinvar_20231028.vcf.gz) was used. In order to be compatible with our hg38-aligned VCFs, we additionally downloaded the [variant summary](https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz) file, ran a [custom script](scripts/cleanup_clinvar.py) that:
  - Converted contigs to `chr` format
  - Dropped contigs not in hg38
  - Use the variant summary table to replace `N` alleles and split into canonical `ACGT` alleles as those `N` were actually representing extended IUPAC nucleotides

Command run:
```sh
scripts/cleanup_clinvar.py --input_vcf clinvar_20231028.vcf.gz --variant_summary variant_summary.txt.gz --update_json docs/update_clinvar.json --output_filename clinvar_20231028.hg38_fmt.vcf.gz --threads 4
```