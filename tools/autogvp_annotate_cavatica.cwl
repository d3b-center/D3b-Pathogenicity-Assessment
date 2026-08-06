cwlVersion: v1.2
class: CommandLineTool
id: autogvp_annotate
doc: |
  Tool for the 02-annotate_variants.R script from AutoGVP
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: $(inputs.ram * 1000)
    coresMin: $(inputs.cpu)
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/diskin-lab/autogvp:v2.0.1'

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      Rscript /rocker-build/AutoGVP/scripts/02-annotate_variants.R --outdir .

inputs:
  vcf_file: { type: 'File', inputBinding: { position: 2, prefix: "--vcf" }, doc: "Input vcf file with VEP annotations" }
  clinvar_file: { type: 'File', inputBinding: { position: 2, prefix: "--clinvar" }, doc: "ClinVar resolved clinical significance file (format: resolved-clinvar-interpretations.tsv)" }
  multianno_file: { type: 'File', inputBinding: { position: 2, prefix: "--multianno" }, doc: "input multianno file" }
  autopvs1_file: { type: 'File', inputBinding: { position: 2, prefix: "--autopvs1" }, doc: "input autopvs1 file" }
  intervar_file: { type: 'File', inputBinding: { position: 2, prefix: "--intervar" }, doc: "input intervar file" }
  output_basename: { type: 'string?', default: "test", inputBinding: { position: 2, prefix: "--output" }, doc: "String to use as base for output filenames" }
  sample_id: {type: 'string', inputBinding: { position: 2, prefix: "--sample_id" }, doc: "Input sample bioassay id."}
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task" }
  ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to this task" }
outputs:
  annotation_report: { type: 'File', outputBinding: { glob: '*.annotations_report.abridged.tsv' }}
