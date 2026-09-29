# Golden-v1 private audio set

The tracked `manifest.csv` contains labels and relative paths only. Keep audio outside Git in a
private store. Add a row only after the recording's source license permits this evaluation or
the speaker has given explicit informed consent. In particular, confirm redistribution and
derived-clip terms before using third-party recitations.

Each `path` is relative to the audio root passed to `eval.run_eval`; paths must be unique and may
not escape that root. Positive rows need a valid `surah`, `ayah_start`, and `ayah_end`. `negative`
rows leave all three labels empty. The allowed `condition` values and target counts are defined
in `docs/09-TESTING-QA.md`.

Do not store reference transcript text in the manifest. The evaluator obtains clean-full
references from the normalized search database and writes only labels, candidates, scores,
aggregate metrics, and latency data. It does not write audio or transcript strings. Keep the
generated per-sample JSON under the ignored `services/api/eval/output/` directory and restrict
access to it because it contains sample labels and model outputs.

For GitHub Actions, store a gzip tar archive of the audio files in private object storage, with
archive paths matching the manifest paths. Configure the repository secret
`GOLDEN_V1_ARCHIVE_URL` with a short-lived or access-controlled download URL; optionally configure
`GOLDEN_V1_ARCHIVE_TOKEN` when the object store accepts a bearer token. The workflow validates
archive paths, extracts the audio only into its temporary runner, and does not upload it as an
artifact. Until the private dataset is available, the workflow writes a `blocked` report and makes
no accuracy claim. Full target counts are required before metrics can serve as release-gate
evidence.
