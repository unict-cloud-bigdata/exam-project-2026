# CCBD Exam 2026 — Flight Delays Analysis <!-- omit in toc -->

Example exam project for **Cloud Computing and Big Data** (AA 2025-2026, Università di Catania). The deliverable is a **self-documenting local Jupyter notebook** that drives Google BigQuery, runs six predefined analytical queries on the 2015 US flight-delays dataset, and narrates the findings with inline visualizations. A **Data Studio dashboard** is provided as a separate deliverable.

> Setup and "how to run" live here. 
> *What the analysis does and why* is explained inline in the notebook itself.

This README mirrors the six project stages of [`ExamProjectBrief2026.md`](./ExamProjectBrief2026.md).

The idea: your **full project** is complete and **shared with the instructors at least three days before the exam** (see [`ExamProjectBrief2026.md`](./ExamProjectBrief2026.md)). For the live demonstration **during the oral exam**, you keep a separate **live stub project** — pre-filled with only *part* of the full project's artifacts — on which you reproduce a few quick steps in front of the instructors.

To support that demo, the callouts in this README are labelled:

> **Pre-exam:** what to set up on the live stub *before* the exam.
>
> **Live at exam:** what you actually do on the live stub *during* the exam.

You are not expected to touch the full project during the exam — only the stub.

## Contents <!-- omit in toc -->

- [Pipeline](#pipeline)
- [Repository layout](#repository-layout)
- [Prerequisites](#prerequisites)
- [1. Cloud Setup](#1-cloud-setup)
  - [1.1 Service account \& key](#11-service-account--key)
    - [Security recommendations](#security-recommendations)
- [2. Data Ingestion](#2-data-ingestion)
  - [Download](#download)
  - [Clean your data — drop October 2015 (in the local CSV, before upload)](#clean-your-data--drop-october-2015-in-the-local-csv-before-upload)
  - [(Optional) Subsample for faster upload and processing](#optional-subsample-for-faster-upload-and-processing)
  - [Upload to Cloud Storage with `gcloud`](#upload-to-cloud-storage-with-gcloud)
  - [List the uploaded files (Cloud Shell)](#list-the-uploaded-files-cloud-shell)
  - [Local environment (venv, kernel \& how to run)](#local-environment-venv-kernel--how-to-run)
- [3. Data Manipulation in BigQuery](#3-data-manipulation-in-bigquery)
  - [Run the queries from the shell with `bq` (optional)](#run-the-queries-from-the-shell-with-bq-optional)
- [4. Data Analysis with Spark](#4-data-analysis-with-spark)
- [5. Data Enrichment (ML)](#5-data-enrichment-ml)
- [6. Data Visualization (Data Studio)](#6-data-visualization-data-studio)
- [Notes — cost \& correctness](#notes--cost--correctness)


## Pipeline

`Kaggle CSVs → drop October → Cloud Storage → BigQuery tables → notebook analysis (6 queries)
→ ML (BigQuery ML) → Data Studio dashboard`

The Spark / Google Colab stage is deferred and not part of this repository yet.

## Repository layout

- [`README.md`](./README.md) — this file; environment & how to run
- [`ExamProjectBrief2026.md`](./ExamProjectBrief2026.md) — original exam brief (authoritative requirements)
- [`flight_delays.ipynb`](./flight_delays.ipynb) — main self-documenting notebook; the deliverable
- [`requirements.txt`](./requirements.txt) — pinned deps (pip freeze after first run; see §2)
- [`sql/`](./sql/) — the six analytical queries (one `.sql` each)
- [`data/`](./data/) — raw CSVs (from Kaggle, etc.); empty on remote GH repo, for you to fill

The service-account key (`*.json`) is **never** stored in the repo.

## Prerequisites

- Python 3.11+ and `pip`
- A Google Cloud project with billing enabled (see step 1)
- The `gcloud` CLI on your PC (should be authenticated in advance) — or use **Cloud Shell**, where `gcloud` is preinstalled
- A Kaggle account (to download the dataset)

## 1. Cloud Setup

> **Pre-exam:** the live stub project and its bucket already exist (you create them ahead of time — creation is *not* demonstrated live).
>
> **Live at exam:** authenticate to GCP, then show the stub project and its bucket.

**Local shell only — authenticate first** (details follow).
<details closed>

<summary></summary>

While Cloud Shell is already authenticated to your GCP account, if you'd rather work from your own machine, log your CLI as follows in *without* auto-launching a browser (you paste the verification code yourself). 

```bash
gcloud auth login --no-launch-browser   # prints a URL; open it, approve, paste the code back
```

One login covers `gcloud`, `bq`, and `gsutil`.

</details>

**Create the project and the bucket** either from **Cloud Shell** (commands below) or from the **web console** (Console → project picker → *New Project*; Console → *Cloud Storage* → *Buckets* → *Create*).

- Project: `ccbd-20260603-gpappa`
- Bucket: `gs://ccbd-20260603-gpappa-bucket`
- Region: `europe-west8` (Milano) — keep the bucket, the BigQuery dataset and everything else in the **same** region.

> **Personalize before running.** `20260603` (a project-creation date stamp) and `gpappa` (student nick) are examples — replace both with your own. GCP project IDs must be **globally unique** and **6–30 characters** (lowercase letters, digits, hyphens); the date + nick keeps the ID collision-resistant and within length (here: 20 chars).

```bash
gcloud projects create ccbd-20260603-gpappa --name="CCBD Exam 2026"
gcloud config set project ccbd-20260603-gpappa
gcloud storage buckets create gs://ccbd-20260603-gpappa-bucket \
  --location=europe-west8 --uniform-bucket-level-access
```

**Billing must be active** on the project (details follow).
<details closed>
<summary></summary>

BigQuery and Cloud Storage require it,
even though our usage stays within the free tier. Check it (and link an account) 
from the Google Cloud web console, or from the shell, thus:

```bash
gcloud billing projects describe ccbd-20260603-gpappa     # look for billingEnabled: true
gcloud billing accounts list                              # find your billing account id
gcloud billing projects link ccbd-20260603-gpappa --billing-account=XXXXXX-XXXXXX-XXXXXX
```

**Too many linked projects?** A billing account caps how many projects can be linked
to it (the cap is low on free-trial accounts), so the `link` above may fail. List
what's already linked and unlink an unused one to free a slot:

```bash
gcloud billing projects list --billing-account=XXXXXX-XXXXXX-XXXXXX   # projects on this account
gcloud billing projects unlink OLD_PROJECT_ID                         # detach an unused one
```

**In the web console:** open the navigation menu (☰) → **Billing**. 
- If the current project is unlinked, click: → **Manage billing accounts** → **Your billing accounts** → **`ACCOUNT-NAME`** → **Manage billing account**.
- If the current project is linked, click **Manage billing account**.

Now under *Account management*, you'll see the list of projects already linked to the account — on each row's **⋮** (3 dots) **→ Disable billing** unlinks a project (do this if you have exceeded your quota). 

To (re)link the current project, its **Billing** page shows **Link a billing account** when it has none (do this if you have part of your quota left).

</details>

**Exam requirement** 
> Please share the GCP project with the instructors (IAM role *Viewer*) **at least 3 days before** the exam.
> 
> Do: Console → IAM & Admin → IAM → *Grant Access* → instructor's email → role
> *Viewer* → Save.
>
> On sharing, see also [`ExamProjectBrief2026.md`](./ExamProjectBrief2026.md#1-cloud-setup).

### 1.1 Service account & key

The notebook authenticates with a **service-account key (JSON)**, which makes it
portable across machines. From the **web console** — you must be **Owner** or
**Project IAM Admin** to grant the roles:

1. **Create the account:** IAM & Admin → *Service Accounts* → *Create*.
2. **Grant its roles** (easy to miss — skip it and the notebook fails with
   `bigquery.jobs.create` denied): on the **project**, *BigQuery Job User* +
   *BigQuery Data Editor* + *BigQuery Read Session User*; on the **bucket**, *Storage Object Admin*. Do it in
   IAM & Admin → IAM → *Grant access*, or in the *Service Accounts* creation wizard's
   *Grant access* step.
3. **Create the key:** open the account → *Keys* → *Add key* → *Create new key* → *JSON*.

*Alternative: get service account and key with the Cloud Shell (details follow).*
<details>

<summary></summary>

```bash
SA=ccbd-exam-2026-sa
PROJECT=ccbd-20260603-gpappa

gcloud iam service-accounts create $SA --display-name="CCBD notebook"

gcloud projects add-iam-policy-binding $PROJECT \
  --member="serviceAccount:$SA@$PROJECT.iam.gserviceaccount.com" \
  --role="roles/bigquery.jobUser"
gcloud projects add-iam-policy-binding $PROJECT \
  --member="serviceAccount:$SA@$PROJECT.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataEditor"
# Fast result downloads via the BigQuery Storage Read API (used by to_dataframe / the %%bigquery magic):
gcloud projects add-iam-policy-binding $PROJECT \
  --member="serviceAccount:$SA@$PROJECT.iam.gserviceaccount.com" \
  --role="roles/bigquery.readSessionUser"
# Storage write scoped to the bucket only (not project-wide):
gcloud storage buckets add-iam-policy-binding gs://ccbd-20260603-gpappa-bucket \
  --member="serviceAccount:$SA@$PROJECT.iam.gserviceaccount.com" \
  --role="roles/storage.objectAdmin"

gcloud iam service-accounts keys create ./ccbd-exam-2026-sa-key.json \
  --iam-account=$SA@$PROJECT.iam.gserviceaccount.com
```

</details>

**Verify the roles landed** before opening the notebook (substitute your SA email):

```bash
SA=ccbd-exam-2026-sa@ccbd-20260603-gpappa.iam.gserviceaccount.com
gcloud projects get-iam-policy ccbd-20260603-gpappa \
  --flatten="bindings[].members" --filter="bindings.members:$SA" \
  --format="table(bindings.role)"
# expect: roles/bigquery.jobUser, roles/bigquery.dataEditor, roles/bigquery.readSessionUser
```

Once you have created the service account and downloaded the key for it and the project, point the application at the key file via an environment variable (the notebook reads this variable, the key file path is never hardcoded in the notebook):

```bash
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/ccbd-exam-2026-sa-key.json"
```

#### Security recommendations

- **Never commit the key.** Add it to `.gitignore` *before* the first commit.
- **Never print the key** or hardcode its path in a notebook cell.
- Roles granted to the service account are least-privilege and Storage write is scoped to the bucket — the account is **not** Owner.
- Rotate or, even better, delete the key after the exam.

To avoid publishing keys, if you were to host your version of this directory on GitHub (not required!), this could be a minimal, security-conscious `.gitignore`:

```gitignore
*.json
data/*
.venv/
__pycache__/
.ipynb_checkpoints/
```

## 2. Data Ingestion

> **Pre-exam:** download, clean, and upload the CSVs to the stub's GCS bucket.
>
> **Live at exam:** list the uploaded files (`gcloud storage ls …`) and walk through the cleaning rationale.

Get the data onto your machine, clean it, upload it to the bucket, list it — and
set up the local Python environment used from here on.

### Download

**What.** USDOT *"2015 Flight Delays and Cancellations"* — Kaggle dataset
`usdot/flight-delays`, licence **CC0** (public domain). Three CSV files:

| File           | Role                                                | Size                |
| -------------- | --------------------------------------------------- | ------------------- |
| `flights.csv`  | fact table — one row per flight (31 columns)        | ~565 MB, ~5.8M rows |
| `airlines.csv` | lookup `IATA_CODE` → airline name                   | tiny (14 carriers)  |
| `airports.csv` | lookup `IATA_CODE` → airport, city, state, lat/lon  | tiny (322 airports) |

**From where.** <https://www.kaggle.com/datasets/usdot/flight-delays>
(a free Kaggle account is required; accept the dataset terms once).

**How** — pick one:

- **Browser:** open the URL → **Download** (top-right) → you get one zip (~190 MB)
  → extract the three CSVs into `data/`.
- **Kaggle CLI** (needs an API token at `~/.kaggle/kaggle.json`):

  ```bash
  kaggle datasets download -d usdot/flight-delays -p data/ --unzip
  ```

The three CSVs must end up in local directory `data/`. The Kaggle archive may unzip into the
project root instead — if so, move them in:

```bash
mkdir -p data
mv flights.csv airlines.csv airports.csv data/
ls -lh data/        # flights.csv ~565 MB, airlines.csv, airports.csv
```

### Clean your data — drop October 2015 (in the local CSV, before upload)

October 2015 is removed **before upload**: that month stores the airport fields as
numeric codes instead of IATA codes, which breaks the joins to `airports.csv`.
Dropping those rows at the root keeps the BigQuery table clean, so no query needs a
`MONTH != 10` filter. Details follow.

<details closed>

<summary></summary>

Every data row starts with `YEAR,MONTH,…`, i.e. `2015,10,…` for October, so we drop
lines that begin with `2015,10,`. The leading `^…,` anchor matters — a bare
`grep ',10,'` would also match `DAY=10`, flight numbers, delays, and so on.

```bash
# keep the header and every non-October row
grep -v '^2015,10,' data/flights.csv > data/flights_clean.csv

# sanity checks: fewer lines, header still present, zero October rows left
wc -l data/flights.csv data/flights_clean.csv
head -1 data/flights_clean.csv
grep -c '^2015,10,' data/flights_clean.csv      # must print 0
```

On the 2015 data this removes **486,165** October rows (**5,819,079 → 5,332,914**
flight rows).

> **Check the layout first.** This assumes column 1 = `YEAR` (always `2015`) and
> column 2 = `MONTH`. Confirm with `head -1 data/flights.csv`; if the column order
> differs, use the field-aware form instead:
> `awk -F, 'NR==1 || $2 != 10' data/flights.csv > data/flights_clean.csv`.

</details>

### (Optional) Subsample for faster upload and processing
<details closed>
<summary></summary>

The full `flights_clean.csv` is ~520 MB, so the upload to Cloud Storage can be slow.
For quick iteration, build a **random** subset and upload that instead — random, not
the first N rows (those would all be January and skew the seasonal query):

```bash
# ~10% random sample, seeded so it differs each run; the header (NR==1) is always kept
awk 'BEGIN { srand() } NR == 1 || rand() < 0.10' data/flights_clean.csv > data/flights_sample.csv
wc -l data/flights_sample.csv      # ~533k data rows + header
```

Averages and rates stay close to the full data; absolute counts scale down ~10x.
Lower the fraction if it is still slow. In the **Upload** step below, use
`data/flights_sample.csv` in place of `data/flights_clean.csv`. For the final
deliverable, upload the full file (querying it is free at this scale).

</details>

### Upload to Cloud Storage with `gcloud`

> **Important — disable parallel composite upload first.** For large files `gcloud
> storage cp` defaults to splitting the upload into parts and reassembling them as a
> GCS *composite object*. BigQuery cannot read composite objects and will create an
> empty table (0 bytes). Disable it once:
> ```bash
> gcloud config set storage/parallel_composite_upload_enabled False
> ```

Upload the **clean** flights file (not the raw one) plus the two lookups:

```bash
gcloud storage cp data/flights_clean.csv data/airlines.csv data/airports.csv \
  gs://ccbd-20260603-gpappa-bucket/
```

### List the uploaded files (Cloud Shell)

```bash
gcloud storage ls gs://ccbd-20260603-gpappa-bucket/
# classic equivalent: gsutil ls gs://ccbd-20260603-gpappa-bucket/
```

### Local environment (venv, kernel & how to run)

Set this up once; every stage that runs the notebook reuses it. Two prongs together
give an isolated, reproducible env **and** a notebook that runs end-to-end on a
clean machine. Details follow.

<details open>

<summary></summary>

**a) Dedicated virtual environment registered as a Jupyter kernel** — so JupyterLab
uses the isolated env, not the global Python:

```bash
python -m venv .venv
source .venv/bin/activate            # Windows: .venv\Scripts\activate
pip install ipykernel jupyterlab
python -m ipykernel install --user --name ccbd --display-name "CCBD"
jupyter kernelspec list              # verify: the "ccbd" kernel must appear in the list
```

**b) Pinned bootstrap cell at the top of the notebook** so it is self-contained ("open → Run All"). The notebook uses the `%pip` magic — **not** `!pip`. `%pip` installs into the *kernel's* environment (i.e., `CCBD`); beware that `!pip` within the notebook may target a different interpreter and cause `ImportError`:

```bash
%pip install -q \
    pandas==2.2.2 matplotlib==3.9.2 \
    google-cloud-bigquery==3.25.0 db-dtypes==1.2.0 pyarrow==17.0.0
```

These are the exact versions pinned for this project. Separately,
`pip freeze > requirements.txt` snapshots the **full** resolved environment as a lock
file — it lets you (or a grader) recreate the venv with `pip install -r requirements.txt`.
The notebook itself does **not** read it; it self-installs via the `%pip` cell above.

**Run it** (from stage 3 onward):

```bash
source .venv/bin/activate
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/ccbd-exam-2026-sa-key.json"
jupyter lab
```

Open the notebook, select the **CCBD** kernel, and run all cells. All queries run directly against
BigQuery, on the full table (free at this scale).

</details>

## 3. Data Manipulation in BigQuery

> **Pre-exam:** the CSVs are already in the stub's GCS bucket; the `.sql` query files are on your disk.
>
> **Live at exam:** load the tables, run the six queries in the BigQuery UI and in the notebook, then export the results to GCS.

- Load the three CSVs from Cloud Storage into tables in a BigQuery dataset (same region, `europe-west8`), via the **BigQuery web console** (as the brief requires) and/or `bq load`. 
- The **six predefined queries** are then uploaded to the project in BigQuery.
- The queries are executed, and explained, in the **BigQuery UI**.
- Results of the query are exported back to Cloud Storage.
- Queries should then be run in the **local Jupyter notebook**.
 
  Note that the queries themselves — SQL, charts, and narrative — live in the notebook (`flight_delays.ipynb`), this README only outlines the stage.

### Run the queries from the shell with `bq` (optional)

<details closed>

<summary></summary>

The six queries are saved as standalone files under `sql/`. Besides the notebook and the BigQuery UI, you can run them straight from the shell.

One-time — create the dataset (same region as the bucket) and load the three tables:

```bash
bq --location=europe-west8 mk --dataset ccbd-20260603-gpappa:flights_2015

# flights has numeric columns, so --autodetect reliably detects + names from the header
bq load --replace --autodetect --skip_leading_rows=1 --source_format=CSV \
  flights_2015.flights   gs://ccbd-20260603-gpappa-bucket/flights_clean.csv   # or flights_sample.csv

# The lookups are all-string (airlines) / mostly-string: --autodetect cannot tell the
# header from the data, so it would name columns string_field_0, string_field_1, ...
# Pass an explicit schema instead (--skip_leading_rows=1 still drops the header line).
bq load --replace --skip_leading_rows=1 --source_format=CSV \
  flights_2015.airlines  gs://ccbd-20260603-gpappa-bucket/airlines.csv \
  IATA_CODE:STRING,AIRLINE:STRING
bq load --replace --skip_leading_rows=1 --source_format=CSV \
  flights_2015.airports  gs://ccbd-20260603-gpappa-bucket/airports.csv \
  IATA_CODE:STRING,AIRPORT:STRING,CITY:STRING,STATE:STRING,COUNTRY:STRING,LATITUDE:FLOAT,LONGITUDE:FLOAT
```

Run each query — cost-aware: preview bytes with `--dry_run`, cap with
`--maximum_bytes_billed`:

```bash
bq query --use_legacy_sql=false --dry_run < sql/q1_ontime_by_airline.sql
bq query --use_legacy_sql=false --maximum_bytes_billed=2000000000 \
         --format=pretty < sql/q1_ontime_by_airline.sql

# all six in sequence
for f in sql/q*.sql; do echo "=== $f ==="; \
  bq query --use_legacy_sql=false --format=pretty < "$f"; done
```

The `.sql` files reference tables as `flights_2015.<table>` using the default
project, so run `gcloud config set project ccbd-20260603-gpappa` first (or add
`--project_id=…`).

</details>

## 4. Data Analysis with Spark

> **Pre-exam:** have a stub copy of your full Colab notebook, connected to the Managed Service for Apache Spark and ready on Google Colab.
>
> **Live at exam:** load your data from your local PC or GCS into the stub Colab notebook, and perform a quick live re-run of your queries (Spark SQL and Spark operators).

**Deferred — not part of this repository yet.**

## 5. Data Enrichment (ML)

> **Pre-exam:** the ML cells are part of the shared notebook; the BigQuery ML model is trained and evaluated there.
>
> **Live at exam:** walk through the model and its metrics in the notebook; re-run the prediction if time allows (fast at this scale).

Binary classification — predict **arrival delay > 15 min** (the DOT threshold) from
features known before arrival. **BigQuery ML** (logistic regression / boosted trees)
now; **Spark MLlib** later. This runs inside the same notebook — the venv and
**CCBD** kernel were already prepared in step 2 (*Local environment*), so no extra
setup is needed. Details in the notebook.

## 6. Data Visualization (Data Studio)

> **Pre-exam:** build the dashboard over the BigQuery tables/views and confirm it loads.
>
> **Live at exam:** demo it interactively — filters, date controls, drill-downs — all backed by live BigQuery queries.

A **Data Studio** dashboard over the BigQuery results (or the exported tables), as a
separate deliverable that highlights the key relationships found in the analysis.

## Notes — cost & correctness

- **Cost is negligible at this scale.** BigQuery bills by bytes scanned; the table
  sits well under the 10 GiB free storage, and a full scan is ~0.5 GB against the
  1 TiB/month free query tier (cached repeats are free), so iteration stays free.
- Stay cost-aware anyway: use `dry_run` to preview bytes scanned and set
  `maximum_bytes_billed` as a guardrail.
- Sanity-check results against known ground-truth anchors (total flights, total
  cancellations, a familiar carrier) so a query that runs cleanly but computes the
  wrong thing is caught early.
