# Tarteel Whisper model conversion

The converter pins `tarteel-ai/whisper-base-ar-quran` to revision `e3f4a5f3f5336a1f0e43a2c2bdae62a680c53a8c`, creates the fast tokenizer file missing from the upstream snapshot, and converts the checkpoint to CTranslate2 int8 for faster-whisper.

From `services/api`, install the conversion extra and run the conversion plus the EveryAyah acceptance check:

```sh
uv sync --extra dev --extra model-conversion
uv run python ../../tools/convert_model/convert.py --verify-audio
```

The source and converted files are generated under the ignored root `models/` directory. The audio check downloads `Alafasy_128kbps/001002.mp3` to a temporary directory, checks it against `الحمد لله رب العالمين` after the shared Arabic normalizer, and removes the clip afterward. It fails if normalized RapidFuzz similarity is below 90.

The Docker build runs conversion in a dedicated stage and copies only the int8 model into the runtime image. The upstream model card reports Apache-2.0; retain model attribution in release materials.
