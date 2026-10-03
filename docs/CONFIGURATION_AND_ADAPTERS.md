# Configuration and provider adapters

SuRT-GeoHarmonizer v1.4 separates provider preparation from the generic administrative-unit harmonization engine. The generic engine remains `R/harmonize_admin_raster.R`. A declarative JSON job tells the runner what raster artifact to use, which boundaries and variable to summarize, how raw values are transformed, what QA contract applies, the required coverage threshold, the output constraints, and the provenance statement.

This is a development contract. Existing Rwanda provider builders are being migrated behind it during the v1.4 reviewer-remediation cycle. Do not infer that every historical builder already uses the adapter layer.

## Files

- `config/harmonization-job.schema.json`: machine-readable JSON Schema for the common job contract.
- `config/demo-harmonization.json`: account-free example configuration.
- `python/config_contract.py`: strict standard-library validation used at runtime.
- `python/provider_adapters.py`: adapter protocol, built-in registry, and external plugin loader.
- `python/fixture_external_adapter.py`: account-free external plugin used to prove that `module:factory` works without a core-registry edit.
- `python/run_configured_harmonization.py`: validated configuration-to-R CLI bridge.
- `python/test_config_contract.py`: fail-closed configuration and adapter regressions, including positive and malformed external-plugin cases.

The Python validator intentionally mirrors the distributed JSON Schema without requiring a JSON-Schema package. This keeps the core account-free pathway dependency-light while still publishing a machine-readable schema for editors, IDEs, and external validators.

## Bring your own raster and boundaries

1. Prepare a raster that `terra::rast()` can read and a polygon or multipolygon boundary file that `sf::st_read()` can read.
2. Give the boundary table a unique non-empty identifier field.
3. Copy `config/demo-harmonization.json` and change the provider path, boundary path, identifier field, variable name, layer, raw-value transforms, coverage threshold, output constraints, and provenance.
4. Keep `provider.adapter` as `local_raster` when the raster is already prepared. This adapter deliberately accepts `qa.mode: none` only. Provider-specific QA belongs in a provider adapter rather than being implied by the generic engine.
5. Validate the configuration without requiring the referenced generated files:

```text
python python/run_configured_harmonization.py --config my-job.json --validate-only
```

6. Run the job after the raster and boundaries exist:

```text
python python/run_configured_harmonization.py --config my-job.json
```

The configured transform thresholds `na_below` and `na_above` are in raw/source raster units and are applied by the R core before scale and offset. `aggregation.method` is currently fixed to `surface_area_weighted_mean`. `aggregation.min_valid_fraction` applies to overall polygon valid-data coverage, not merely coverage inside the raster footprint. Output CRS is currently fixed to EPSG:4326.

## Stable adapter contract

A provider adapter performs acquisition and preparation needed before the generic harmonizer sees a raster. It must expose:

```text
name: str
validate_options(options, qa) -> None
prepare(options, qa, root) -> PreparedRaster
```

`prepare()` returns `PreparedRaster(path=..., provenance_suffix=...)`. The returned raster must be readable by the generic R core. An adapter may implement provider-specific acquisition, subdataset selection, QA filtering, temporal aggregation, mosaicking, or reprojection. It must fail closed when its declared requirements are not satisfied.

The generic core does not import provider code. `python/run_configured_harmonization.py` loads the configured adapter, asks it for a prepared raster, and then calls the unchanged generic R interface.

## External provider plugin without editing core code

`provider.adapter` may use `module:factory` instead of a built-in name. The module must be importable on `PYTHONPATH`; the named zero-argument factory must return an object implementing the adapter contract.

Example:

```python
from pathlib import Path
from python.provider_adapters import PreparedRaster

class ExampleAdapter:
    name = "example_provider"

    def validate_options(self, options, qa):
        if set(options) != {"prepared_path"}:
            raise ValueError("expected prepared_path only")
        if qa.get("mode") != "none":
            raise ValueError("this adapter does not implement QA")

    def prepare(self, options, qa, root: Path):
        self.validate_options(options, qa)
        path = (root / options["prepared_path"]).resolve()
        if not path.is_file():
            raise ValueError(f"missing prepared raster: {path}")
        return PreparedRaster(path=path, provenance_suffix="Example provider adapter")


def create_adapter():
    return ExampleAdapter()
```

The corresponding configuration uses:

```json
{
  "provider": {
    "adapter": "my_package.example:create_adapter",
    "options": {"prepared_path": "data/example.tif"}
  }
}
```

The surrounding job still supplies the standard boundaries, variable, transform, aggregation, QA, output, and provenance sections required by the schema.

The extension path is executable evidence, not only documentation. `python/fixture_external_adapter.py` lives outside the built-in `_BUILTINS` registry. The account-free contract test loads `fixture_external_adapter:make_adapter`, prepares a declared fixture artifact, checks its provenance contribution, and separately verifies that a malformed factory result and undeclared options are rejected. This proves the external loading boundary itself while making no claim that every third-party provider is already implemented.

## QA ownership

QA is explicit in every job. The common schema provides `qa.mode` and `qa.options`, but the selected adapter decides which QA modes it implements. `local_raster` supports only `none` because it assumes provider-specific QA has already been completed upstream. A MODIS adapter, for example, can require a documented pixel-reliability policy and expose its accepted ranks through `qa.options` without changing the generic zonal engine.

## Adapter testing requirements

A new adapter should add account-free tests wherever possible and real-data numerical checks when provider access permits. At minimum, test:

- valid option parsing;
- missing and unknown options;
- missing input or credentials;
- QA policy validation;
- exact prepared-raster contract;
- provenance contribution;
- one deliberate malformed-input failure;
- one integration path into `run_configured_harmonization.py`.

Provider credentials must remain external. Never commit tokens, cookies, API keys, or credential files. Controlled fixtures are software verification, not independent validation of the provider product.
