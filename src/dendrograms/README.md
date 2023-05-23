## Store R dendrograms and generate robot template TSVs

### File Naming

Store dendrogram JSON files as {accession}.json and associated tsvs as {accession}.tsv, where {accession} = standard
Allen dendrogram accession e.g. CCN202002013

### (re)Generating robot template TSVs

WARNING: Be careful about overwriting TSVs containing curation!

To (re)generate all templates:

    `./run.sh make all`
    
To extend the set of recognised accessions for build, edit the list of JOBS in the makefile
    
To (re)generate templates for a single dendrogram:

   `./run.sh JOBS={accession}` (note no spaces)
   
 To (re)generate a single template
 
   `./run.sh make {template relative path)` e.g. `run.sh make ../CCN201908210_class.tsv`
 
## Data Sources

  - https://alleninstitute.sharepoint.com/sites/BICANHumanandNHPAtlas/Shared%20Documents/Forms/AllItems.aspx?ga=1&id=%2Fsites%2FBICANHumanandNHPAtlas%2FShared%20Documents%2FWG%5FIntegrative%20Cell%2DType%20Taxonomy%20and%20Ontology%2Fadult%2Dhuman%2Dbrain%5Fv1&viewid=b12e2161%2D72ac%2D4523%2D822e%2Dea1cbd794874  

  - https://cellxgene.cziscience.com/collections/283d65eb-dd53-496d-adb7-7570c7caa443   

  - https://www.biorxiv.org/content/10.1101/2022.10.12.511898v1.supplementary-material
