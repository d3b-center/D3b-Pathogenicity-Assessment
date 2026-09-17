cwlVersion: v1.2
class: Workflow
id: autogvp
label: AutoGVP Workflow
doc: |
  # AutoGVP: Automated Germline Variant Pathogenicity Workflow

  This workflow is a Common Workflow Language (CWL) implementation of the
  [AutoGVP bash script](https://github.com/diskin-lab-chop/AutoGVP/blob/main/run_autogvp.sh).
  Other than downloading files, this workflow contains all the functionality of
  the bash script.

  AutoGVP is a "tool that integrates germline variant pathogenicity annotations
  from ClinVar and sequence variant classifications from a modified version of
  InterVar (PVS1 strength adjustments, removal of PP5/BP6). This tool facilitates
  large-scale, clinically focused classification of germline sequence variants in
  a research setting."

  Please refer to the [AutoGVP publication](https://doi.org/10.1093/bioinformatics/btae114)
  for a detailed description of the software.

  ## Inputs

  ```yaml
  vcf_file: Input VCF file. Can be either VEP-annotated VCF file or or VEP- and ClinVar-annotated VCF file
  filter_criteria: Any additional VCF filtering criteria
  intervar_file: InterVar results file
  autopvs1_file: AutoPVS1 results file
  multianno_file: ANNOVAR multianno file
  output_colnames: File with custom column name information
  output_basename: String to use as the basename for stored outputs
  selected_clinvar_submissions: ClinVar variant file with conflicts resolved. If not provided, this file will be generated in the workflow
  variant_summary_file: ClinVar variant summary file
  submission_summary_file: ClinVar submission summary file
  concept_ids: File containing list of conceptIDs to prioritize submissions for ClinVar variant conflict resolution
  conflict_res: How to resolve conflicts associated with conceptIDs: latest or most_severe
  ```

  The following files can be obtained from the [AutoGVP GitHub data directory](https://github.com/diskin-lab-chop/AutoGVP/tree/main/data):
  - `autopvs1_file`
  - `concept_ids`
  - `intervar_file`
  - `multianno_file`
  - `output_colnames`

  Additionally, AutoGVP provides [a bash script](https://github.com/diskin-lab-chop/AutoGVP/blob/main/scripts/download_db_files.sh) to obtain:
  - `submission_summary_file`
  - `variant_summary_file`

  ## Outputs

  ```yaml
    abridged: output file with minimal information needed to interpret variant pathogenicity
    full: output file with >100 variant annotation columns
  ```

  ## Resources

  Dockerfile: pgc-images.sbgenomics.com/diskin-lab/autogvp:v2.0.2
  AutoGVP Paper: https://doi.org/10.1093/bioinformatics/btae114
  AutoGVP GitHub: https://github.com/diskin-lab-chop/AutoGVP
requirements:
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement
- class: MultipleInputFeatureRequirement
inputs:
  vcf_file: {type: 'File', doc: "Input VCF file. Can be either VEP-annotated VCF file or or VEP- and ClinVar-annotated VCF file"}
  filter_criteria: {type: 'string[]?', doc: "Any additional VCF filtering criteria"}
  intervar_file: {type: 'File', doc: "InterVar results file"}
  autopvs1_file: {type: 'File', doc: "AutoPVS1 results file"}
  multianno_file: {type: 'File', doc: "ANNOVAR multianno file"}
  output_colnames: {type: 'File?', doc: "File with custom column name information."}
  output_basename: {type: 'string?', default: "out", doc: "String to use as the basename for stored outputs."}
  sample_id: {type: 'string', doc: "Input sample bioassay id."}
  selected_clinvar_submissions: {type: 'File?', doc: "ClinVar variant file with conflicts resolved. If not provided, this file will
      be generated in the workflow", "sbg:suggestedValue": {class: File,
      path: 6a834cde08505474f85ea6f1, name: resolved-clinvar-2026-06-cancer-latest.tsv}}
  variant_summary_file: {type: 'File?', doc: "ClinVar variant summary file", "sbg:suggestedValue": {class: File,
      path: 6a322ff1b729272b1d1bbe9b, name: variant_summary_2026-06.txt.gz}}
  clinvar_hgvs4_file: {type: 'File?', doc: "ClinVar hgvs4 file with amino acid changes", "sbg:suggestedValue": {class: File,
      path: 6a68726f08505474f85a109b, name: hgvs4variation-2026-07.txt.gz}}
  submission_summary_file: {type: 'File?', doc: "ClinVar submission summary file", "sbg:suggestedValue": {class: File,
      path: 6a322ff1b729272b1d1bbea2, name: submission_summary_2026-06.txt.gz}}
  concept_ids: {type: 'File?', doc: "File containing list of conceptIDs to prioritize submissions for ClinVar variant conflict resolution",
      "sbg:suggestedValue": {class: File, path: 6a322ff1b729272b1d1bbe93, name: clinvar_cancer_concept_ids_20260130.txt}}
  conflict_res: {type: ['null', {type: enum, symbols: ["latest", "most_severe"], name: "conflict_resolution"}], doc: "How to resolve
      conflicts associated with conceptIDs: latest or most_severe"}
  annotate_cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to AutoGVP annotation" }
  annotate_ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to AutoGVP annotation" }
  filter_annot_cpu: { type: 'int?', default: 1, doc: "CPUs to allocate to AutoGVP filter annotations" }
  filter_annot_ram: { type: 'int?', default: 2, doc: "GB of RAM to allocate to AutoGVP filter annotations" }
outputs:
  abridged: {type: 'File', outputSource: filter_annotations/abridged_output, doc: "output file with minimal information needed to
      interpret variant pathogenicity"}
  full: {type: 'File', outputSource: filter_annotations/full_output, doc: "output file with >100 variant annotation columns"}
steps:
  select_clinvar_subs:
    run: ../tools/autogvp_select_clinvar_subs.cwl
    when: $(inputs.selected_submissions == null)
    in:
      selected_submissions: selected_clinvar_submissions
      variant_summary: variant_summary_file
      submission_summary: submission_summary_file
      conceptid_list: concept_ids
      conflict_res: conflict_res
    out: [clinvar_submissions]
  filter_vcf:
    run: ../tools/autogvp_filter_vcf.cwl
    in:
      vcf_file: vcf_file
      multianno_file: multianno_file
      autopvs1_file: autopvs1_file
      intervar_file: intervar_file
      output_basename: output_basename
      filter_criteria: filter_criteria
    out: [filtered_vcf, filtered_multianno, filtered_autopvs1, filtered_intervar]
  update_intervar:
    run: ../tools/autogvp_update_intervar.cwl
    in:
      intervar_file: filter_vcf/filtered_intervar
      clinvar_file:
        source: [selected_clinvar_submissions, select_clinvar_subs/clinvar_submissions]
        pickValue: first_non_null
      clinvar_hgvs4_file: clinvar_hgvs4_file
    out: [updated_intervar]
  annotate:
    run: ../tools/autogvp_annotate_cavatica.cwl
    in:
      vcf_file: filter_vcf/filtered_vcf
      clinvar_file:
        source: [selected_clinvar_submissions, select_clinvar_subs/clinvar_submissions]
        pickValue: first_non_null
      multianno_file: filter_vcf/filtered_multianno
      autopvs1_file: filter_vcf/filtered_autopvs1
      intervar_file: update_intervar/updated_intervar
      output_basename: output_basename
      sample_id: sample_id
      cpu: annotate_cpu
      ram: annotate_ram
    out: [annotation_report]
  parse_vcf:
    run: ../tools/autogvp_parse_vcf.cwl
    in:
      vcf_file: filter_vcf/filtered_vcf
    out: [parsed_tsv, csq_subfields_tsv]
  filter_annotations:
    run: ../tools/autogvp_filter_annotations.cwl
    in:
      vcf_file: parse_vcf/parsed_tsv
      autogvp_file: annotate/annotation_report
      output_colnames_file: output_colnames
      csq_subfields: parse_vcf/csq_subfields_tsv
      output_basename: output_basename
      cpu: filter_annot_cpu
      ram: filter_annot_ram
    out: [abridged_output, full_output]

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
