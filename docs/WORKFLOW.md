# Workflow orchestration

SuRT-GeoHarmonizer v1.4 adds a Snakemake workflow layer so the steps required to turn an input artifact into validated administrative-unit output are represented as an executable dependency graph rather than as an implied sequence of manual commands.

The workflow is deliberately split from provider credentials. The committed default DAG uses deterministic synthetic fixtures and can run on a clean machine without a data-provider account. This verifies software orchestration only. It does not count as independent numerical validation of CHIRPS, ERA5-Land, MODIS, HAND, or another Earth-observation product.

## Pinned workflow engine

Install the workflow dependency:

```text
python -m pip install -r requirements-workflow.txt
```

The current v1.4 development pin is `snakemake==9.27.0`.

## Run the account-free DAG

From the repository root:

```text
snakemake --cores 1 --printshellcmds --rerun-incomplete
```

The final target is:

```text
generated/workflow_demo/evidence.json
```

The generated directory is ignored by Git. CI uploads the workflow evidence alongside the normal SoftwareX evidence bundle.

## Explicit stages

The `Snakefile` declares these dependencies:

1. `acquire_controlled_fixture` creates a deterministic two-layer raster and three projected polygon units. The word acquire refers only to creation of the controlled test fixture in this default account-free DAG.
2. `transform_provider_raster` explicitly selects the named signal layer and writes the one-layer prepared raster.
3. `validate_declarative_config` validates the machine-readable job contract and adapter options without requiring provider credentials.
4. `harmonize_administrative_units` invokes `python/run_configured_harmonization.py`, which resolves the configured adapter and translates the declarative job into the generic `R/harmonize_admin_raster.R` command.
5. `validate_harmonized_output` checks identifiers, transformed values, spatial support fractions, provenance, and expected fail-closed semantics of the deterministic fixture.
6. `build_workflow_evidence` hashes all prerequisite artifacts and records the evidence class, workflow engine, stage names, and limitations.

The fixture deliberately includes one raw no-data sentinel. After raw-unit masking followed by scale and offset, the expected administrative means are 16, 36, and 51. The third unit has overall valid-data coverage of 0.5. This makes the DAG exercise both transformation order and non-silent partial support.

## Relationship to provider adapters

The default configuration uses `provider.adapter: local_raster` because the preceding Snakemake transform rule produces an already prepared raster. The adapter boundary is nevertheless explicit. An external provider can implement the documented `module:factory` contract in `docs/CONFIGURATION_AND_ADAPTERS.md` and return a prepared raster without modifying the generic R aggregation engine.

Existing Rwanda provider builders are not yet claimed to be fully migrated behind provider adapters. Real-provider acquisition, QA, temporal aggregation, and independent numerical validation remain separate v1.4 remediation gates. A future provider-specific DAG must preserve the same stage boundaries and expose credentials only through external provider-standard configuration.

## Failure visibility

Snakemake stops downstream execution when a prerequisite rule fails or an expected output is missing. The scripts also fail closed on missing layers, missing artifacts, malformed configuration, unsupported QA policy, invalid harmonizer output, or unexpected numerical results. `--rerun-incomplete` is used in CI so interrupted outputs are rebuilt instead of being accepted as complete evidence.
