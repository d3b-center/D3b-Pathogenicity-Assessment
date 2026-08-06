cwlVersion: v1.2
class: CommandLineTool
id: autogvp_annotate_cavatica
doc: |
  Tool for the 04-filter_gene_annotations.R script from AutoGVP

  This scripts reads in filtered, subfield-parsed VEP VCF file, and further parses
  VEP `CSQ` subfield such that there is a unique gene annotation row for each
  variant. This data frame is then merged with AutoGVP output, and full
  and abbreviated results files are written to output.
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/diskin-lab/autogvp:v2.0.1'
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.csq_subfields)

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      Rscript /rocker-build/AutoGVP/scripts/04-filter_gene_annotations.R --outdir .

inputs:
  vcf_file: { type: 'File', inputBinding: { position: 2, prefix: "--vcf" }, doc: "Input filtered and parsed VEP VCF file" }
  autogvp_file: { type: 'File', inputBinding: { position: 2, prefix: "--autogvp" }, doc: "input AutoGVP annotated file" }
  output_colnames_file: { type: 'File?', inputBinding: { position: 2, prefix: "--output_colnames" }, doc: "file listing custom output colnames" }
  csq_subfields: { type: 'File', doc: "VCF file CSQ field names" }
  output_basename: { type: 'string?', default: "test", inputBinding: { position: 2, prefix: "--output" }, doc: "String to use as base for output filenames" }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task" }
  ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to this task" }
outputs:
  abridged_output: { type: 'File', outputBinding: { glob: '*-autogvp-annotated-abridged.tsv' }}
  full_output: { type: 'File', outputBinding: { glob: '*-autogvp-annotated-full.tsv' }}
