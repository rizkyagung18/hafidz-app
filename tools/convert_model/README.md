# Tarteel Whisper model conversion

The converter pins `tarteel-ai/whisper-base-ar-quran` to revision `e3f4a5f3f5336a1f0e43a2c2bdae62a680c53a8c`, creates the fast tokenizer file missing from the upstream snapshot, and converts the checkpoint to CTranslate2 int8 for faster-whisper.

From `services/api`, install the conversion extra and run the conversion:

```sh
uv sync --extra dev --extra model-conversion
uv run python ../../tools/convert_model/convert.py
```

The source and converted files are generated under the ignored root `models/` directory. No external recitation is downloaded. Optional verification requires a supplied local QUL clip and its canonical ayah key; the expected text is read from the pinned QUL `quran.sqlite`:

```sh
uv run python ../../tools/convert_model/convert.py --verify-audio --audio-file /path/to/qul-clip.mp3 --ayah 1:2
```

Verification enforces a 90-percent normalized similarity threshold. An audio check is unavailable until an appropriate QUL recitation source is supplied. This source change leaves model conversion and ASR inference behavior unchanged.

The Docker build runs conversion in a dedicated stage and copies only the int8 model into the runtime image. The upstream model card reports Apache-2.0; retain model attribution in release materials.
