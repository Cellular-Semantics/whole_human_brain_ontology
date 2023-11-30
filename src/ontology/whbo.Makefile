## Customize Makefile settings for whbo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


#IMPORTS += simple_human simple_marmoset

JOBS = CS202210140
#GENE_LIST = ensmusg simple_human simple_marmoset
GENE_LIST = simple_human
BDS_BASE = http://purl.obolibrary.org/obo/
ONTBASE=                    $(URIBASE)/pcl

TSV_CLASS_FILES = $(patsubst %, $(TMPDIR)/%_class.tsv, $(JOBS))
#TSV_CLASS_HOMOLOGOUS_FILES = $(patsubst %, ../patterns/data/default/%_class_homologous.tsv, $(JOBS))
TSV_MARKER_SET_FILES = $(patsubst %, ../patterns/data/default/%_marker_set.tsv, $(JOBS))

OWL_FILES = $(patsubst %, components/%.owl, $(JOBS))
OWL_CLASS_FILES = $(patsubst %, components/%_class.owl, $(JOBS))
OWL_CLASS_HOMOLOGOUS_FILES = $(patsubst %, components/%_class_homologous.owl, $(JOBS))
OWL_MARKER_SET_FILES = $(patsubst %, components/%_marker_set.owl, $(JOBS))
GENE_FILES = $(patsubst %, mirror/%.owl, $(GENE_LIST))
OWL_APP_SPECIFIC_FILES = $(patsubst %, components/%_app_specific.owl, $(JOBS))
OWL_DATASET_FILES = $(patsubst %, components/%_dataset.owl, $(JOBS))
OWL_TAXONOMY_FILE = components/taxonomies.owl
OWL_PROTEIN2GENE_FILE = components/Protein2GeneExpression.owl
PCL_LEGACY_FILE = components/pcl-legacy.owl

OWL_OBSOLETE_INDVS = $(patsubst %, components/%_obsolete_indvs.owl, $(JOBS))
OWL_OBSOLETE_TAXONOMY_FILE = components/taxonomies_obsolete.owl

# overriding to add prefixes
$(PATTERNDIR)/pattern.owl: $(ALL_PATTERN_FILES)
	if [ $(PAT) = true ]; then $(DOSDPT) prototype --prefixes=template_prefixes.yaml --obo-prefixes true --template=$(PATTERNDIR)/dosdp-patterns --outfile=$@; fi

$(PATTERNDIR)/data/default/%.txt: $(PATTERNDIR)/dosdp-patterns/%.yaml $(PATTERNDIR)/data/default/%.tsv .FORCE
	if [ $(PAT) = true ]; then $(DOSDPT) terms --prefixes=template_prefixes.yaml --infile=$(word 2, $^) --template=$< --obo-prefixes=true --outfile=$@; fi

# adding more imports (simple_human simple_marmoset) to process
#IMPORT_ROOTS = $(patsubst %, imports/%_import, $(IMPORTS))
#IMPORT_OWL_FILES = $(foreach n,$(IMPORT_ROOTS), $(n).owl)
#IMPORT_FILES = $(IMPORT_OWL_FILES)

#ALL_TERMS_COMBINED = $(patsubst %, imports/%_terms_combined.txt, $(IMPORTS))
#imports/merged_terms_combined.txt: $(ALL_TERMS_COMBINED)
#	if [ $(IMP) = true ]; then cat $^ | grep -v ^# | sort | uniq >  $@; fi

$(IMPORTDIR)/%_import.owl: $(MIRRORDIR)/merged.owl $(IMPORTDIR)/%_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/inject-version-info.ru --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/$*_terms_combined.txt --force true --copy-ontology-annotations true --individuals exclude --method BOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

.PRECIOUS: $(IMPORTDIR)/%_import.owl

## ONTOLOGY: simple_human
.PHONY: mirror-simple_human
.PRECIOUS: $(MIRRORDIR)/simple_human.owl
mirror-simple_human: ../templates/simple_human.tsv .FORCE
	if [ $(MIR) = true ]; then $(ROBOT) template --input $(SRC) --template ../templates/simple_human.tsv \
      --add-prefixes template_prefixes.json \
      annotate --ontology-iri ${BDS_BASE}mirror/simple_human.owl \
      convert --format ofn --output $(MIRRORDIR)/simple_human.owl; fi

#$(IMPORTDIR)/ensmusg_import.owl: mirror/ensmusg.owl imports/ensmusg_terms_combined.txt
#	if [ $(IMP) = true ]; then $(ROBOT) query  -i $< --update ../sparql/inject-version-info.ru --update ../sparql/preprocess-module.ru \
#		extract -T imports/ensmusg_terms_combined.txt --force true --copy-ontology-annotations true --individuals exclude --method BOT \
#		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
#		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi
#
#.PRECIOUS: $(IMPORTDIR)/ensmusg_import.owl

# DISABLE automatic DOSDP pattern management. Manually managed below
$(PATTERNDIR)/definitions.owl: $(TSV_CLASS_FILES)
	if [ $(PAT) = "skip" ] && [ "${DOSDP_PATTERN_NAMES_DEFAULT}" ]   && [ $(PAT) = true ]; then $(ROBOT) merge $(addprefix -i , $^) \
		annotate --ontology-iri $(ONTBASE)/patterns/definitions.owl  --version-iri $(ONTBASE)/releases/$(TODAY)/patterns/definitions.owl \
      --annotation owl:versionInfo $(VERSION) -o definitions.ofn && mv definitions.ofn $@; fi
$(DOSDP_OWL_FILES_DEFAULT):
	if [ $(PAT) = "skip" ] && [ "${DOSDP_PATTERN_NAMES_DEFAULT}" ]; then $(DOSDPT) generate --catalog=catalog-v001.xml \
    --infile=$(PATTERNDIR)/data/default/ --template=$(PATTERNDIR)/dosdp-patterns --batch-patterns="$(DOSDP_PATTERN_NAMES_DEFAULT)" \
    --ontology=$< --obo-prefixes=true --outfile=$(PATTERNDIR)/data/default; fi
update_patterns:
	if [ $(PAT) = "skip" ]; then cp -r $(TMPDIR)/dosdp/*.yaml $(PATTERNDIR)/dosdp-patterns; fi

# disable automatic term management and manually manage below
$(PATTERNDIR)/data/default/%.txt: $(PATTERNDIR)/dosdp-patterns/%.yaml $(PATTERNDIR)/data/default/%.tsv .FORCE
	if [ $(PAT) = 'skip' ]; then $(DOSDPT) terms --infile=$(word 2, $^) --template=$< --obo-prefixes=true --outfile=$@; fi

$(PATTERNDIR)/data/default/%_class_base.txt: $(PATTERNDIR)/data/default/%_class_base.tsv $(TSV_CLASS_FILES) .FORCE
	if [ $(PAT) = true ]; then $(DOSDPT) terms --infile=$< --template=$(PATTERNDIR)/dosdp-patterns/taxonomy_class.yaml --obo-prefixes=true --prefixes=template_prefixes.yaml --outfile=$@; fi

$(PATTERNDIR)/data/default/%_class_curation.txt: $(PATTERNDIR)/data/default/%_class_curation.tsv $(TSV_CLASS_FILES) .FORCE
	if [ $(PAT) = true ]; then $(DOSDPT) terms --infile=$< --template=$(PATTERNDIR)/dosdp-patterns/taxonomy_class.yaml --obo-prefixes=true --prefixes=template_prefixes.yaml --outfile=$@; fi

#$(PATTERNDIR)/data/default/%_class_homologous.txt: $(PATTERNDIR)/data/default/%_class_homologous.tsv $(TSV_CLASS_FILES) .FORCE
#	if [ $(PAT) = true ]; then $(DOSDPT) terms --infile=$< --template=$(PATTERNDIR)/dosdp-patterns/taxonomy_class_homologous.yaml --obo-prefixes=true --prefixes=template_prefixes.yaml --outfile=$@; fi

$(PATTERNDIR)/data/default/%_marker_set.txt: $(PATTERNDIR)/data/default/%_marker_set.tsv $(TSV_MARKER_SET_FILES) .FORCE
	if [ $(PAT) = true ]; then $(DOSDPT) terms --infile=$< --template=$(PATTERNDIR)/dosdp-patterns/taxonomy_marker_set.yaml --obo-prefixes=true --prefixes=template_prefixes.yaml --outfile=$@; fi

#$(PATTERNDIR)/data/default/Protein2GeneExpression.txt: $(PATTERNDIR)/data/default/Protein2GeneExpression.tsv .FORCE
#	if [ $(PAT) = true ]; then $(DOSDPT) terms --infile=$< --template=$(PATTERNDIR)/dosdp-patterns/Protein2GeneExpression.yaml --obo-prefixes=true --prefixes=template_prefixes.yaml --outfile=$@; fi


# merge class template data
$(TMPDIR)/%_class.tsv: $(PATTERNDIR)/data/default/%_class_base.tsv $(PATTERNDIR)/data/default/%_class_curation.tsv
	python ../scripts/template_runner.py modifier --merge -i=$< -i2=$(word 2, $^) -o=$@

# hard wiring for now.  Work on patsubst later
#mirror/ensmusg.owl: ../templates/ensmusg.tsv .FORCE
#	if [ $(MIR) = true ]; then $(ROBOT) template --input $(SRC) --template $< \
#      --add-prefixes template_prefixes.json \
#      annotate --ontology-iri ${BDS_BASE}$@ \
#      convert --format ofn --output $@; fi
#	if [ $(MIR) = true ]; then $(ROBOT) template --input $(SRC) --template ../templates/simple_human.tsv \
#      --add-prefixes template_prefixes.json \
#      annotate --ontology-iri ${BDS_BASE}mirror/simple_human.owl \
#      convert --format ofn --output mirror/simple_human.owl; fi
#	if [ $(MIR) = true ]; then $(ROBOT) template --input $(SRC) --template ../templates/simple_marmoset.tsv \
#      --add-prefixes template_prefixes.json \
#      annotate --ontology-iri ${BDS_BASE}mirror/simple_marmoset.owl \
#      convert --format ofn --output mirror/simple_marmoset.owl; fi

#.PRECIOUS: mirror/simple_human.owl
#.PRECIOUS: imports/simple_human_import.owl
#.PRECIOUS: mirror/simple_marmoset.owl
#.PRECIOUS: imports/simple_marmoset_import.owl

# merge all templates except application specific ones
.PHONY: $(COMPONENTSDIR)/all_templates.owl
$(COMPONENTSDIR)/all_templates.owl: $(OWL_FILES) $(OWL_CLASS_FILES) $(OWL_MARKER_SET_FILES)
	$(ROBOT) merge $(patsubst %, -i %, $(filter-out $(OWL_APP_SPECIFIC_FILES), $^)) \
	 --collapse-import-closure false \
	 annotate --ontology-iri ${BDS_BASE}$@  \
	 convert -f ofn	 -o $@

.PRECIOUS: $(COMPONENTSDIR)/all_templates.owl

components/%.owl: ../templates/%.tsv $(EDIT_PREPROCESSED)
	$(ROBOT) template --input $(EDIT_PREPROCESSED) --template $< \
    		--add-prefixes template_prefixes.json \
    		annotate --ontology-iri ${BDS_BASE}$@ \
    		convert --format ofn --output $@

components/%_class.owl: $(TMPDIR)/%_class.tsv $(PATTERNDIR)/dosdp-patterns/taxonomy_class.yaml $(EDIT_PREPROCESSED)
	$(DOSDPT) generate --catalog=catalog-v001.xml --prefixes=template_prefixes.yaml \
        --infile=$< --template=$(PATTERNDIR)/dosdp-patterns/taxonomy_class.yaml \
        --ontology=$(EDIT_PREPROCESSED) --obo-prefixes=true --outfile=$@

#components/%_class_homologous.owl: $(PATTERNDIR)/data/default/%_class_homologous.tsv $(SRC) $(PATTERNDIR)/dosdp-patterns/taxonomy_class_homologous.yaml $(SRC) all_imports .FORCE
#	$(DOSDPT) generate --catalog=catalog-v001.xml --prefixes=template_prefixes.yaml \
#        --infile=$< --template=$(PATTERNDIR)/dosdp-patterns/taxonomy_class_homologous.yaml \
#        --ontology=$(SRC) --obo-prefixes=true --outfile=$@

components/%_marker_set.owl: $(PATTERNDIR)/data/default/%_marker_set.tsv $(SRC) $(PATTERNDIR)/dosdp-patterns/taxonomy_marker_set.yaml $(EDIT_PREPROCESSED)
	$(DOSDPT) generate --catalog=catalog-v001.xml --prefixes=template_prefixes.yaml \
        --infile=$< --template=$(PATTERNDIR)/dosdp-patterns/taxonomy_marker_set.yaml \
        --ontology=$(EDIT_PREPROCESSED) --obo-prefixes=true --outfile=$@

#components/taxonomies.owl: ../templates/Taxonomies.tsv $(SRC)
#	$(ROBOT) template --input $(SRC) --template $< \
#    		--add-prefixes template_prefixes.json \
#    		annotate --ontology-iri ${BDS_BASE}$@ \
#    		convert --format ofn --output $@
#
#components/taxonomies_obsolete.owl: ../templates/Taxonomies_obsolete.tsv $(SRC)
#	$(ROBOT) template --input $(SRC) --template $< \
#    		--add-prefixes template_prefixes.json \
#    		annotate --ontology-iri ${BDS_BASE}$@ \
#    		convert --format ofn --output $@
#
#components/%_obsolete_indvs.owl: ../templates/%_obsolete_indvs.tsv $(SRC)
#	$(ROBOT) template --input $(SRC) --template $< \
#    		--add-prefixes template_prefixes.json \
#    		annotate --ontology-iri ${BDS_BASE}$@ \
#    		convert --format ofn --output $@ \
#
#components/Protein2GeneExpression.owl: $(PATTERNDIR)/data/default/Protein2GeneExpression.tsv $(PATTERNDIR)/dosdp-patterns/Protein2GeneExpression.yaml $(SRC) all_imports .FORCE
#	$(DOSDPT) generate --catalog=catalog-v001.xml --prefixes=template_prefixes.yaml \
#        --infile=$< --template=$(PATTERNDIR)/dosdp-patterns/Protein2GeneExpression.yaml \
#        --ontology=$(SRC) --obo-prefixes=true --outfile=$@
#
## release a legacy ontology to support older versions of the PCL
#components/pcl-legacy.owl: ../resources/pCL_4.1.0.owl components/pCL_mapping.owl
#	$(ROBOT) query --input ../resources/pCL_4.1.0.owl --update ../sparql/delete-legacy-properties.ru \
#			query --update ../sparql/delete-non-pcl-terms.ru \
#			query --update ../sparql/postprocess-module.ru \
#			remove --select ontology \
#			merge --input components/pCL_mapping.owl \
#			annotate --ontology-iri $(ONTBASE)/pcl.owl  \
#			--link-annotation dc:license http://creativecommons.org/licenses/by/4.0/ \
#			--annotation owl:versionInfo $(VERSION) \
#			--annotation dc:title "Provisional Cell Ontology" \
#			--output $@
#
#components/pCL_mapping.owl: ../templates/pCL_mapping.tsv ../resources/pCL_4.1.0.owl
#	$(ROBOT) template --input ../resources/pCL_4.1.0.owl --template $< \
#    		--add-prefixes template_prefixes.json \
#    		convert --format ofn --output $@
#
#components/%_app_specific.owl: ../templates/%_app_specific.tsv allen_helper.owl
#	$(ROBOT) template --input allen_helper.owl --template $< \
#    		--add-prefixes template_prefixes.json \
#    		annotate --ontology-iri ${BDS_BASE}$@ \
#    		convert --format ofn --output $@ \
#
#components/%_dataset.owl: ../templates/%_dataset.tsv $(SRC)
#	$(ROBOT) template --input $(SRC) --template $< \
#    		--add-prefixes template_prefixes.json \
#    		annotate --ontology-iri ${BDS_BASE}$@ \
#    		convert --format ofn --output $@ \


## Release additional artifacts
#$(ONT).owl: $(ONT)-full.owl $(ONT)-allen.owl $(ONT)-pcl-comp.owl $(ONT)-pcl-comp.obo $(ONT)-pcl-comp.json
#	$(ROBOT) annotate --input $< --ontology-iri $(URIBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
#		convert -o $@.tmp.owl && mv $@.tmp.owl $@
#
## Allen app specific ontology (with color information etc.) (Used for Solr dump)
#$(ONT)-allen.owl: $(ONT)-full.owl allen_helper.owl
#	$(ROBOT) merge -i $< -i allen_helper.owl $(patsubst %, -i %, $(OWL_APP_SPECIFIC_FILES)) \
#			 annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
#		 	 --output $(RELEASEDIR)/$@
#
## Artifact that extends base with gene ontologies (used by PCL)
#$(ONT)-pcl-comp.owl:  $(ONT)-base.owl $(GENE_FILES)
#	$(ROBOT) merge -i $< $(patsubst %, -i %, $(GENE_FILES)) \
#	query --update ../sparql/remove_preflabels.ru \
#			 annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
#		 	 --output $(RELEASEDIR)/$@
#$(ONT)-pcl-comp.obo: $(RELEASEDIR)/$(ONT)-pcl-comp.owl
#	$(ROBOT) convert --input $< --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $(RELEASEDIR)/$@ && rm $@.tmp.obo
#$(ONT)-pcl-comp.json: $(RELEASEDIR)/$(ONT)-pcl-comp.owl
#	$(ROBOT) annotate --input $< --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
#		convert --check false -f json -o $@.tmp.json &&\
#	jq -S 'walk(if type == "array" then sort else . end)' $@.tmp.json > $(RELEASEDIR)/$@ && rm $@.tmp.json


# skip schema checks for now, because odk using the wrong validator
#.PHONY: pattern_schema_checks
#pattern_schema_checks: update_patterns
#	if [ $(PAT) = "skip" ]; then $(PATTERN_TESTER) $(PATTERNDIR)/dosdp-patterns/  ; fi

## ONTOLOGY: uberon (remove disjoint classes and properties, they are cousing inconsistencies when merged with hba and hba bridge)
.PHONY: mirror-uberon
.PRECIOUS: $(MIRRORDIR)/uberon.owl
mirror-uberon: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/uberon/uberon-base.owl --create-dirs -o $(MIRRORDIR)/uberon.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/uberon.owl -o $@.tmp.owl && \
		$(ROBOT) remove -i $@.tmp.owl --axioms disjoint -o $@.tmp.owl && \
		 mv $@.tmp.owl $(TMPDIR)/$@.owl; fi


 ## ONTOLOGY: ro (remove [material entity](http://purl.obolibrary.org/obo/BFO_0000040) DisjointWith [part_of](http://purl.obolibrary.org/obo/BFO_0000050) some [immaterial entity](http://purl.obolibrary.org/obo/BFO_0000141))
.PHONY: mirror-ro
.PRECIOUS: $(MIRRORDIR)/ro.owl
mirror-ro: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then curl -L $(OBOBASE)/ro/ro-base.owl --create-dirs -o $(MIRRORDIR)/ro.owl --retry 4 --max-time 200 &&\
		$(ROBOT) convert -i $(MIRRORDIR)/ro.owl -o $@.tmp.owl && \
		robot query -i $@.tmp.owl --update ../sparql/remove_material_disjoint.ru -o $@.tmp.owl && \
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi


## ONTOLOGY: hba_uberon_bridge (Only equivalent classes that have been asserted are allowed. Inferred equivalencies are forbidden. HBA:9219 vs 9230)
.PHONY: mirror-hba_uberon_bridge
.PRECIOUS: $(MIRRORDIR)/hba_uberon_bridge.owl
mirror-hba_uberon_bridge: | $(TMPDIR)
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I https://raw.githubusercontent.com/obophenotype/uberon/master/src/ontology/bridge/uberon-bridge-to-hba.owl -o $@.tmp.owl &&\
		robot query -i $@.tmp.owl --update ../sparql/remove_hba_inf_equals.ru -o $@.tmp.owl && \
		mv $@.tmp.owl $(TMPDIR)/$@.owl; fi
