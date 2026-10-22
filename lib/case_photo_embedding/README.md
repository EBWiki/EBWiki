# Case photo embeddings (SigLIP 2)

Whole-image vectors for link-only case photos (`photo_status: shown`). Used for "more photos like this" and spotting the same image across import sources. No face detection, cropping, or upload-to-search.

Model: `google/siglip2-base-patch16-224` (Apache-2.0, 768 dimensions), CPU only.

## Run the embed job

Set `DATABASE_URL`, install Python deps, then:

```bash
pip install -r lib/case_photo_embedding/python/requirements.txt
export PYTHONPATH=lib/case_photo_embedding/python
export HF_HOME=/tmp/huggingface
python3 -m case_photo_embedding.job
```

Or from Rails (same env vars):

```bash
bin/rails case_photo_embedding:run
```

The job logs `shown_count` and `embedded_count` and exits non-zero when they differ.

## Outbound network

HTTP from the job is limited to each case `photo_url` host plus Hugging Face hosts for one-time model weights. Postgres uses the database driver, not HTTP. Tests live in `python/tests/test_network_policy.py`.

## Similar cases

```ruby
CasePhotoEmbedding::SimilarCases.ranked_by_embedding(case_record.photo_embedding)
CasePhotoEmbedding::SimilarCases.more_like_this(case_record)
```

Errors go through `ErrorReporter` (Sentry when loaded, otherwise Rollbar).
