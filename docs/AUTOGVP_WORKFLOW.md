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
workflow: Indicate whether the input VCF is from a cavatica or custom workflow
vcf_file: Input VCF file. Can be either VEP-annotated VCF file or or VEP- and ClinVar-annotated VCF file
filter_criteria: Any additional VCF filtering criteria
clinvar_file: ClinVar file. Required for inputs from a custom workflow!
intevar_file: InterVar results file
autopsv1_file: AutoPVS1 results file
multianno_file: ANNOVAR multianno file
output_colnames: File with column name information
output_basename: String to use as the basename for stored outputs
selected_clinvar_submissions: ClinVar variant file with conflicts resolved. If not provided, this file will be generated in the workflow
variant_summary_file: ClinVar variant summary file
submission_summary_file: ClinVar submission summary file
concept_ids: File containing list of conceptIDs to prioritize submissions for ClinVar variant conflict resolution
conflict_res: How to resolve conflicts associated with conceptIDs: latest or most_severe
```

The following files can be obtained from the [AutoGVP GitHub data directory](https://github.com/diskin-lab-chop/AutoGVP/tree/main/data):
- `autopsv1_file`
- `concept_ids`
- `intevar_file`
- `multianno_file`
- `output_colnames`

Additionally, AutoGVP provides [a bash script](https://github.com/diskin-lab-chop/AutoGVP/blob/main/scripts/download_db_files.sh) to obtain:
- `clinvar_file`
- `submission_summary_file`
- `variant_summary_file`

## Outputs

```yaml
  abridged: output file with minimal information needed to interpret variant pathogenicity
  full: output file with >100 variant annotation columns
```

## Resources

Dockerfile: pgc-images.sbgenomics.com/diskin-lab/autogvp:v2.0.3
AutoGVP Paper: https://doi.org/10.1093/bioinformatics/btae114
AutoGVP GitHub: https://github.com/diskin-lab-chop/AutoGVP
