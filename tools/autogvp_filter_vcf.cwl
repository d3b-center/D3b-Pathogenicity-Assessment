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
      bash /rocker-build/AutoGVP/scripts/01-filter_vcf.sh
  - position: 8
    shellQuote: false
    valueFrom: "."

inputs:
  vcf_file: { type: 'File', inputBinding: { position: 3 }, doc: "VCF file to filter" }
  multianno_file: { type: 'File', inputBinding: { position: 4 }, doc: "multianno file" }
  autopvs1_file: { type: 'File', inputBinding: { position: 5 }, doc: "autopvs1 results file" }
  intervar_file: { type: 'File', inputBinding: { position: 6 }, doc: "intervar results file" }
  output_basename: { type: 'string?', default: "test", inputBinding: { position: 7 }, doc: "String to use as base for output filenames" }
  filter_criteria: { type: 'string[]?', inputBinding: { position: 9 }, doc: "VCF filtering criteria" }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task" }
  ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to this task" }
outputs:
  filtered_vcf: { type: File, outputBinding: { glob: '*.filtered.vcf' }}
  filtered_multianno: { type: File, outputBinding: { glob: '*_multianno_filtered.txt' }}
  filtered_autopvs1: { type: File, outputBinding: { glob: '*_autopvs1_filtered.tsv' }}
  filtered_intervar: { type: File, outputBinding: { glob: '*_intervar_filtered.txt' }}
