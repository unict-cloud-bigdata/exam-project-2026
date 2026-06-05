# Cloud Computing and Big Data (2025-26) - Exam Project <!-- omit in toc -->

## Contents <!-- omit in toc -->

- [Main Requirements](#main-requirements)
- [Carrying out the Project in Stages](#carrying-out-the-project-in-stages)
  - [1. Cloud Setup](#1-cloud-setup)
  - [2. Data Ingestion](#2-data-ingestion)
  - [3. Data Manipulation and Analysis using BigQuery](#3-data-manipulation-and-analysis-using-bigquery)
    - [3.1 JupyterLab Notebooks and BigQuery](#31-jupyterlab-notebooks-and-bigquery)
  - [4. Data Analysis using Google Colab / Spark Notebooks](#4-data-analysis-using-google-colab--spark-notebooks)
  - [5. Data Enrichment](#5-data-enrichment)
  - [6. Data Visualization](#6-data-visualization)
- [Tools](#tools)
- [Pre-exam checklist](#pre-exam-checklist)
- [Evaluation](#evaluation)
- [Example project](#example-project)

## Main Requirements

Every student must prepare a project to demonstrate the knowledge of the topics covered during the course.
The project needs to be presented during the exam using a PowerPoint slide set or alternative presentation mode (Google Slides are fine too, a dashboard is even better, dashboard + self-documenting notebook would be ideal) describing the results obtained.

During the exam, it is required of candidates to:
- be able to reproduce the key project steps (see below for details)
- answer related questions by the instructors

The project work is structured into stages. The Google project you share with the instructors must be complete, with all stage artifacts and outcomes present and made available.

During the exam, candidates should have the following already in place: 
- a new, empty live stub project created
- the relevant data downloaded to their local machine and uploaded to GCS
- query files (`.sql`) 
- the local notebook (step 3) on their disk
- the Colab notebook (step 4) ready on Google Colab. 
 
Steps to be demonstrated live during the exam are the ones that run fast — essentially those shown during lectures. Candidates may open their own [`README.md`](./README.md), styled after the one in this directory, and copy/paste/adapt commands from it.

## Carrying out the Project in Stages

### 1. Cloud Setup
<details open>
<summary></summary>

   - Create a Google Cloud project, e.g. `ccbd-20260603-gpappa` where `gpappa` is a nickname reflecting your name/surname — remember GCP project IDs must be **globally unique** and **6–30 characters** (lowercase letters, digits, hyphens).
   - Create a Cloud Storage bucket e.g. `ccbd-20260603-gpappa-bucket`, in that project.
   - Share the Google Cloud project with the instructors at least three days in advance
     > **How:** GCP Console → IAM & Admin → IAM → **Grant Access** →
     > enter the instructor's email → Role: **Viewer** (Basic) → Save.
     >
     > Instructors' emails: `gmpappalardo@gmail.com`, `salvatore.nicotra1@unict.it`.
   - Have the live stub project ready: you can use the same naming scheme, making the date that of the exam, e.g. `ccbd-20260623-gpappa`, `ccbd-20260623-gpappa-bucket`.

</details>

### 2. Data Ingestion
<details closed>
<summary></summary>

   - Get a dataset (from Kaggle or alternative sources) and download it to your PC
   - Clean your data if necessary
   - Upload data to Google Cloud Storage (in the previously defined bucket)
   - Use Cloud Shell to list the uploaded files

</details>

### 3. Data Manipulation and Analysis using BigQuery
<details closed>
<summary></summary>

   - Using the BigQuery web console, load your data from Google Cloud Storage into BigQuery tables, having previously defined a suitable BigQuery dataset
   - Define (in advance) in your local `.sql` files, comment and be ready to explain, at least 5 queries on your BigQuery tables.
   - Store your queries into BigQuery, in your project.
   - Run your queries using the BigQuery web console (you are also welcome to run BQ queries from the Cloud Shell).
   - Export query results into the Google Cloud Storage bucket previously defined.

#### 3.1 JupyterLab Notebooks and BigQuery
<details closed>
<summary></summary>

   - Prepare on your PC a local JupyterLab notebook, connect it to BigQuery and submit your queries.
   - The JupyterLab notebook should be as self-documenting as possible, i.e., should motivate and describe the queries and illustrate their output graphically.
   - The charts and tables produced in the notebook are a natural starting point for the Data Studio dashboard ([step 6](#6-data-visualization)): identify the most informative visuals here and plan to surface them as dashboard panels.

</details> 

</details> 


### 4. Data Analysis using Google Colab / Spark Notebooks
<details closed>
<summary></summary>

   - Set up a Google Colab notebook connected to the Managed Service for Apache Spark
   - Load the same dataset as in Steps 2 and 3, from local data stored on your PC into a Spark DataFrame within your Colab notebook, and
     - (*optionally, alternatively or in addition*) read your data from Google Cloud Storage instead.
  
   - Execute the same queries as in Step 3, using your Colab/Spark notebook to perform each query in different ways:
     - with Spark SQL
     - with Spark operators
     - (*optionally*) using Databricks.
  
     You are then expected to discuss the methodological differences among the above options.

</details>

### 5. Data Enrichment
<details closed>
<summary></summary>

   - Execute a machine learning algorithm on your dataset — first in BigQuery, then in Spark using Spark MLlib, Spark NLP, Hugging Face, or an LLM (you are free and welcome to demonstrate more than one technique).

</details>

### 6. Data Visualization
<details closed>
<summary></summary>

<details class="sub">
<summary><strong>Motivation</strong></summary>

Unlike the notebook — a linear narrative for an analyst — a **dashboard** is an interactive, always-live view for a decision-maker, who needs KPIs and key trends at a glance. A dashboard is **explorable through controls** (date sliders, drop-down filters, drill-downs) or enriched with geo maps — all without running code.

</details>

<h4 class="requirements">Requirements</h4>

   - Create a dashboard for your dataset using Data Studio.
   - Build it over the BigQuery tables or views (not static results files: interactivity requires a live connection). 

<details class="sub">
<summary><strong>Data Studio Dashboard Mechanism</strong></summary>

In a nutshell, when the user operates a dashboard control (e.g., moves a slider, clicks a geomap region), Data Studio translates the user's choices into a BigQuery query, executes it on the fly, and refreshes all panels with the filtered result — no code, no re-run, always up to date.

</details>

</details>

## Tools

You are free to use Visual Studio Code and its extensions as you see fit, e.g. to replace the browser-based JupyterLab interface.

## Pre-exam checklist

Before the exam day you should have the following artifacts (detailed in [Main Requirements](#main-requirements)).

> - **Full project**, must be complete and shared with the instructors three days in advance.
>
> - **Live stub project**, must be ready, including: stub project created, GCS bucket created in the latter, data downloaded to your disk and uploaded to GCS bucket, SQL queries stored on your disk, and both notebooks prepared — the local JupyterLab one and the remote Colab one.

## Evaluation

**A key evaluation criterion is how meaningful the relationships you discover within your dataset are, and how effectively you highlight them in your presentation.**

## Example project
See [`README.md`](./README.md) file in this directory.
