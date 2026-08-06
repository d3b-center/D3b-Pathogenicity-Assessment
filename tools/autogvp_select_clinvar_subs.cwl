cwlVersion: v1.2
class: CommandLineTool
id: autogvp_select_clinvar_subs
doc: |
  Tool for the resolve-clinvar-intepretations.R script from AutoGVP
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
      Rscript /rocker-build/AutoGVP/scripts/resolve-clinvar-intepretations.R --outdir .

inputs:
  variant_summary: { type: 'File', inputBinding: { prefix: "--variant_summary", position: 2 }, doc: "ClinVar variant summary file." }
  submission_summary: { type: 'File', inputBinding: { prefix: "--submission_summary", position: 2 }, doc: "ClinVar submission summary file." }
  conceptid_list: { type: 'File?', inputBinding: { prefix: "--conceptID_list", position: 2 }, doc: "File containing list of conceptIDs to prioritize submissions for clinvar variant conflict resolution" }
  conflict_res: {  type: ['null', { type: enum, symbols: ["latest", "most_severe"], name: "conflict_resolution" }], inputBinding: { prefix: "--conflict_res", position: 2 }, doc: "how to resolve conflicts associated with conceptIDs." }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task." }
  ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to this task." }
outputs:
  clinvar_submissions: { type: File, outputBinding: { glob: "resolved-clinvar-*.tsv"} }
