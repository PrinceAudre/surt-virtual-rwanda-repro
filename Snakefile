# SuRT-GeoHarmonizer v1.4 account-free workflow evidence DAG.
# Controlled fixtures verify orchestration only and are not real-data validation.

DEMO = "generated/workflow_demo"
CONFIG = "config/demo-harmonization.json"
SCHEMA = "config/harmonization-job.schema.json"

rule all:
    input:
        f"{DEMO}/evidence.json"

rule acquire_controlled_fixture:
    output:
        raw=f"{DEMO}/raw_multilayer.tif",
        boundaries=f"{DEMO}/units.geojson"
    shell:
        "Rscript R/prepare_workflow_demo_inputs.R {DEMO}"

rule transform_provider_raster:
    input:
        raw=f"{DEMO}/raw_multilayer.tif"
    output:
        prepared=f"{DEMO}/prepared.tif"
    shell:
        "Rscript R/transform_workflow_demo_raster.R {input.raw} {output.prepared} demo_signal"

rule validate_declarative_config:
    input:
        config=CONFIG,
        schema=SCHEMA,
        runner="python/run_configured_harmonization.py",
        contract="python/config_contract.py",
        adapters="python/provider_adapters.py"
    output:
        f"{DEMO}/config_validation.json"
    shell:
        "python python/run_configured_harmonization.py --config {input.config} --validate-only > {output}"

rule harmonize_administrative_units:
    input:
        prepared=f"{DEMO}/prepared.tif",
        boundaries=f"{DEMO}/units.geojson",
        config=CONFIG,
        config_validation=f"{DEMO}/config_validation.json"
    output:
        harmonized=f"{DEMO}/harmonized.geojson"
    shell:
        "python python/run_configured_harmonization.py --config {input.config}"

rule validate_harmonized_output:
    input:
        harmonized=f"{DEMO}/harmonized.geojson"
    output:
        validation=f"{DEMO}/validation.json"
    shell:
        "python python/validate_workflow_demo.py --input {input.harmonized} --output {output.validation}"

rule build_workflow_evidence:
    input:
        config=CONFIG,
        schema=SCHEMA,
        raw=f"{DEMO}/raw_multilayer.tif",
        boundaries=f"{DEMO}/units.geojson",
        prepared=f"{DEMO}/prepared.tif",
        config_validation=f"{DEMO}/config_validation.json",
        harmonized=f"{DEMO}/harmonized.geojson",
        validation=f"{DEMO}/validation.json"
    output:
        evidence=f"{DEMO}/evidence.json"
    shell:
        "python python/build_workflow_evidence.py --output {output.evidence} "
        "{input.config} {input.schema} {input.raw} {input.boundaries} {input.prepared} "
        "{input.config_validation} {input.harmonized} {input.validation}"
