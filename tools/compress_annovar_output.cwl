cwlVersion: v1.2
class: CommandLineTool
id: sort_gzip_index_vcf
doc: "Quick tool to sort, compress and index a vcf file"
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 16000
    coresMin: 8
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/autopvs1:v2.0.0'

baseCommand: [pigz, -c, -p 8]
arguments:
  - position: 1
    shellQuote: false
    valueFrom: >-
      > $(inputs.annovar_txt.nameroot).txt.gz

inputs:
  annovar_txt: {type: File, doc: "annovar txt file to compress", inputBinding: { position: 0 } }

outputs:
  gzipped_txt:
    type: File
    outputBinding:
      glob: '*.txt.gz'
