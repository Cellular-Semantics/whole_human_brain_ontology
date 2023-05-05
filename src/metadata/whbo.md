---
layout: ontology_detail
id: whbo
title: Whole Human Brain Ontology
jobs:
  - id: https://travis-ci.org/hkir-dev/whole_human_brain_ontology
    type: travis-ci
build:
  checkout: git clone https://github.com/hkir-dev/whole_human_brain_ontology.git
  system: git
  path: "."
contact:
  email: 
  label: 
  github: 
description: Whole Human Brain Ontology is an ontology...
domain: stuff
homepage: https://github.com/hkir-dev/whole_human_brain_ontology
products:
  - id: whbo.owl
    name: "Whole Human Brain Ontology main release in OWL format"
  - id: whbo.obo
    name: "Whole Human Brain Ontology additional release in OBO format"
  - id: whbo.json
    name: "Whole Human Brain Ontology additional release in OBOJSon format"
  - id: whbo/whbo-base.owl
    name: "Whole Human Brain Ontology main release in OWL format"
  - id: whbo/whbo-base.obo
    name: "Whole Human Brain Ontology additional release in OBO format"
  - id: whbo/whbo-base.json
    name: "Whole Human Brain Ontology additional release in OBOJSon format"
dependencies:
- id: pr
- id: go
- id: ro
- id: uberon
- id: pato
- id: cl
- id: ncbitaxon
- id: mba

tracker: https://github.com/hkir-dev/whole_human_brain_ontology/issues
license:
  url: http://creativecommons.org/licenses/by/3.0/
  label: CC-BY
activity_status: active
---

Enter a detailed description of your ontology here. You can use arbitrary markdown and HTML.
You can also embed images too.

