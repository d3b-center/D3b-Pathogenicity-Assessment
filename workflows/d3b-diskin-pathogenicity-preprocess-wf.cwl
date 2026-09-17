cwlVersion: v1.2
class: Workflow
id: d3b-diskin-pathogenicity-preprocess-wf
label: Pathogenicity Preprocessing Workflow
doc: |-
  # Pathogenicity Preprocessing Workflow
  This repo makes use of the git submodule feature for ease of code maintenance. To properly retrieve all relevant code:
  ```sh
  git clone  https://github.com/childrens-bti/D3b-Pathogenicity-Preprocessing-CNH
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
requirements:
- class: SubworkflowFeatureRequirement
inputs:
  # Common
  vep_vcf: {type: File, secondaryFiles: [.tbi], doc: "VCF file (with associated index) to be annotated"}
  buildver: {type: ['null', {type: enum, symbols: ["hg38", "hg19", "hg18"], name: "buildver"}], doc: "Genome reference build version",
    default: "hg38"}
  output_basename: {type: string, doc: "String that will be used in the output filenames. Be sure to be consistent with this as InterVar
      will use this too"}
  annovar_db: {type: File, doc: "Annovar Database with at minimum required resources to InterVar", "sbg:suggestedValue": {class: File,
      path: 695d3c4c5ddfaa35efd4d025, name: annovar_humandb_hg38_intervar.tgz}}
  annovar_db_str: {type: 'string?', doc: "Name of dir created when annovar db is un-tarred", default: "annovar_humandb_hg38_intervar"}
  annovar_protocol: {type: 'string?', doc: "csv string of databases within `annovar_db` cache to run", default: "refGene,esp6500siv2_all,1000g2015aug_all,avsnp147,dbnsfp42a,clinvar_20210501,gnomad_genome,dbscsnv11,rmsk,ensGene,knownGene"}
  annovar_operation: {type: 'string?', doc: "csv string of how to treat each listed protocol", default: "g,f,f,f,f,f,f,f,r,g,g"}
  annovar_nastring: {type: 'string?', doc: "character used to represent missing values", default: '.'}
  annovar_otherinfo: {type: 'boolean?', doc: "print out otherinfo (information after fifth column in queryfile)", default: true}
  annovar_threads: {type: 'int?', doc: "Num threads to use to process filter inputs", default: 8}
  annovar_ram: {type: 'int?', doc: "Memory to run tool. Sometimes need more", default: 32}
  annovar_vcfinput: {type: 'boolean?', doc: "Annotate vcf and generate output file as vcf", default: true}
  bcftools_strip_for_intervar: {type: 'string?', doc: "csv string of columns to strip if needed to avoid conflict/improve performance
      of a tool, i.e INFO/CSQ", default: "^INFO/DP"}
  bcftools_strip_for_vep: {type: 'string?', doc: "csv string of columns to strip if needed to avoid conflict/improve performance of
      a tool, i.e INFO/CSQ"}
  bcftools_strip_for_annovar: {type: 'string?', doc: "csv string of columns to strip if needed to avoid conflict/improve performance
      of a tool, i.e INFO/CLNSIG"}
  # bcftools annotate if more to do
  bcftools_annot_columns: {type: 'string?', doc: "csv string of columns from annotation to port into the input vcf", default: "INFO/ALLELEID,INFO/CLNDN,INFO/CLNDNINCL,INFO/CLNDISDB,INFO/CLNDISDBINCL,INFO/CLNHGVS,INFO/CLNREVSTAT,INFO/CLNSIG,INFO/CLNSIGCONF,INFO/CLNSIGINCL,INFO/CLNVC,INFO/CLNVCSO,INFO/CLNVI"}
  annotation_vcf: {type: 'File?', secondaryFiles: ['.tbi'], doc: "additional bgzipped annotation vcf file"}
  intervar_db: {type: File, doc: "InterVar Database from git repo + mim_genes.txt", "sbg:suggestedValue": {class: File, path: 695d3c4c5ddfaa35efd4d023,
      name: intervardb_2021-08.tar.gz}}
  intervar_db_str: {type: 'string?', doc: "Name of dir created when intervar db is un-tarred", default: "intervardb"}
  intervar_ram: {type: 'int?', doc: "Min ram needed for task in GB", default: 32}
  autopvs1_db: {type: File, doc: "git repo files plus a user-provided fasta reference", "sbg:suggestedValue": {class: File, path: 695d3c4c5ddfaa35efd4d02d,
      name: autoPVS1_references_sym_updated.tar.gz}}
  autopvs1_db_str: {type: 'string?', doc: "Name of dir created when annovar db is un-tarred", default: "data"}
outputs:
  intervar_classification: {type: File, outputSource: run_intervar/intervar_classification}
  autopvs1_tsv: {type: File, outputSource: run_autopvs1/autopvs1_tsv}
  annovar_vcfoutput: {type: 'File?', outputSource: [bcftools_strip_annovar/stripped_vcf, run_intervar/annovar_vcfoutput], pickValue: first_non_null}
  annovar_txt: {type: File, outputSource: run_intervar/annovar_txt}
  vep_with_clinvar: {type: 'File?', outputSource: bcftools_annotate/bcftools_annotated_vcf}
steps:
  run_intervar:
    run: intervar_classification_wf.cwl
    in:
      input_vcf: vep_vcf
      annovar_db: annovar_db
      annovar_db_str: annovar_db_str
      buildver: buildver
      output_basename: output_basename
      annovar_protocol: annovar_protocol
      annovar_operation: annovar_operation
      annovar_nastring: annovar_nastring
      annovar_otherinfo: annovar_otherinfo
      annovar_threads: annovar_threads
      annovar_ram: annovar_ram
      annovar_vcfinput: annovar_vcfinput
      bcftools_strip_info: bcftools_strip_for_intervar
      intervar_db: intervar_db
      intervar_db_str: intervar_db_str
      intervar_ram: intervar_ram
    out: [intervar_classification, annovar_vcfoutput, annovar_txt]
  run_autopvs1:
    run: ../tools/autopvs1.cwl
    in:
      autopvs1_db: autopvs1_db
      autopvs1_db_str: autopvs1_db_str
      vep_vcf: vep_vcf
      genome_version: buildver
      output_basename: output_basename
    out: [autopvs1_tsv]
  bcftools_strip_vep:
    when: $(inputs.strip_info != null)
    run: ../kf-annotation-tools/tools/bcftools_strip_ann.cwl
    in:
      input_vcf: vep_vcf
      output_basename: output_basename
      strip_info: bcftools_strip_for_vep
      tool_name:
        valueFrom: "vep"
    out: [stripped_vcf]
  bcftools_strip_annovar:
    when: $(inputs.strip_info != null)
    run: ../kf-annotation-tools/tools/bcftools_strip_ann.cwl
    in:
      input_vcf: vep_vcf
      output_basename: output_basename
      strip_info: bcftools_strip_for_annovar
      tool_name:
        valueFrom: "annovar"
    out: [stripped_vcf]
  bcftools_annotate:
    when: $(inputs.annotation_vcf != null)
    run: ../kf-annotation-tools/tools/bcftools_annotate.cwl
    in:
      input_vcf:
        source: [bcftools_strip_vep/stripped_vcf, vep_vcf]
        pickValue: first_non_null
      annotation_vcf: annotation_vcf
      columns: bcftools_annot_columns
      output_basename: output_basename
      tool_name:
        valueFrom: "vep.clinvar"
    out: [bcftools_annotated_vcf]

$namespaces:
  sbg: https://sevenbridges.com
hints:
- class: sbg:maxNumberOfParallelInstances
  value: 2
"sbg:links":
- id: 'https://github.com/d3b-center/D3b-Pathogenicity-Assessment/releases/tag/v2.0.2'
  label: github-release
sbg:license: Apache License 2.0
sbg:publisher: KFDRC
