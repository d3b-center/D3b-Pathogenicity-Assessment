cwlVersion: v1.2
class: CommandLineTool
id: autogvp_filter_vcf
doc: |
  Tool for the 01-filter_vcf script from AutoGVP
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
      Rscript /rocker-build/AutoGVP/scripts/update_intervar.R --outdir .

inputs:
  intervar_file: { type: 'File', inputBinding: { position: 2, prefix: "--intervar_file" }, doc: "intervar results file" }
  clinvar_file: { type: 'File', inputBinding: { position: 2, prefix: "--clinvar_file" }, doc: "ClinVar resolved clinical significance file (format: resolved-clinvar-interpretations.tsv)" }
  clinvar_hgvs4_file: { type: 'File', inputBinding: { position: 2, prefix: "--clinvar_hgvs4_file" }, doc: "ClinVar hgvs4 file with amino acid changes" }
outputs:
  updated_intervar: { type: File, outputBinding: { glob: '*updated*' }}
