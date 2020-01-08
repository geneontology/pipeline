[![Build Status](https://build.geneontology.org/job/geneontology/job/pipeline/job/release/badge/icon)](https://build.geneontology.org/job/geneontology/job/pipeline/job/release/)

# pipeline

Declarative pipeline for the Gene Ontology.

# QC 

## Manual QC steps
There is a step in the pipeline that halts the pipeline: https://build.geneontology.org/job/geneontology/job/pipeline/job/release/
Currently pgaudet is reponsible for checking the release. Notes for the checks are here: https://docs.google.com/document/d/1IMA54ycbHZxkFbIAyjRvzm_ybAaAj2V8q-Q670mE07U/edit#

Products are here: http://skyhook.berkeleybop.org/release/
AmiGO is here: https://amigo-staging.geneontology.io/amigo

Anomalies are evaluated, reported to the upstream sources and fixed, or ignored if the problem is no worse than the previous release. 

# Troubleshooting

How to manually complete a bum Zenodo archive upload on a production
pipeline.

    1.  go to zenodo for concept/last
    2.  discard if anything is open
    3.  start a new version
    4.  note new entity id (example as E123)
    5.  delete current tarball in UI
    6.  get bucket for new entity
	    (example token T890)
		`curl -H "Accept: application/json" -H "Authorization: Bearer T890" "https://www.zenodo.org/api/deposit/depositions/E123"`
		note bucket id in return (example as B456)
    7.  PUT archive file into bucket:
        `curl -X PUT -H "Accept: application/json" -H "Content-Type: application/octet-stream" -H "Authorization: Bearer T890" -T ./go-release-archive.tgz https://www.zenodo.org/api/files/B456/go-release-archive.tgz`
		(took 41m in last run)
    8.  check md5sum
        `md5sum ./go-release-archive.tgz`
    9.  update/add version info to version manually
	    e.g.: 2018-08-09 in "Version" in "Basic information",
		not "publication date"
    10. publish
    11. generate new doi json
	    `cat release-reference-doi.json`
		copy to local and update with E123
		`mg /tmp/release-archive-doi.json`
    12. upload created file to:
	    go-data-product-current/metadata
	    go-data-product-release/2018-08-09/metadata
	    NOTE that the index.html will not contain this!
    13. invalidate metadata/release-archive-doi.json
    14. celebrate, as this is close enough for the moment until fixing underlying issue
    15. on to deployment: `update-golr` is the only one needed
