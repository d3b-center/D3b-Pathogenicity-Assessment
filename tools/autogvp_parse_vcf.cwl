cwlVersion: v1.2
class: CommandLineTool
id: autogvp_parse_vcf
doc: |
  Tool for the 03-parse_vcf script from AutoGVP
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
      - $(inputs.vcf_file)
  - class: EnvVarRequirement
    envDef:
      - envName: BCFTOOLS_PLUGINS
        envValue: /rocker-build/bcftools-1.17/plugins

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      bash /rocker-build/AutoGVP/scripts/03-parse_vcf.sh $(inputs.vcf_file.path)

inputs:
  vcf_file: { type: 'File', doc: "VCF file to parse" }
  cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to this task" }
  ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to this task" }
outputs:
  parsed_tsv: { type: File, outputBinding: { glob: '*.parsed.tsv' }}
  csq_subfields_tsv: {  type: File, outputBinding: { glob: '*csq_subfields.tsv' }}
