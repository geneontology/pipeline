[![Build Status](https://build.geneontology.org/job/geneontology/job/pipeline/job/release/badge/icon)](https://build.geneontology.org/job/geneontology/job/pipeline/job/release/)

# pipeline

Declarative pipeline for the Gene Ontology.

# QC

## Manual QC steps
There is a step in the pipeline that halts the pipeline: https://build.geneontology.org/job/geneontology/job/pipeline/job/release/
Currently pgaudet is reponsible for checking the release. Notes for the checks are here: https://docs.google.com/document/d/1IMA54ycbHZxkFbIAyjRvzm_ybAaAj2V8q-Q670mE07U/edit#

Products are here: http://skyhook.berkeleybop.org/release/
AmiGO is here: https://amigo-staging.geneontology.io/amigo

Anomalies are evaluated, reported to the upstream sources and fixed, or ignored if the problem is no worse than the previous release.

# Troubleshooting

## Manual finalization from Zenodo failure

This checklist can be used to manually finish a release that has
unrecoverably failed while operating with Zenodo.

- [ ] Go to zenodo for concept/last
- [ ] Discard if anything is open
- [ ] Get the date of the run and the run number to attach it to. For this example:
	- Date: 2020-04-23
	- Build number: 163
- [ ] get the releases into zenodo
	in jenkins@wok:~/workspace/neontology\_pipeline\_release-L3OLSRDNGI3ZIUODKFYUI4AO45X5C6RUGMOQAC5WV2Q6ZQOIFHMA/go-site$
	```
	time python3 ./scripts/zenodo-version-update.py --verbose --key OJBR7cntKKysaXiWHkoVdwVCZp4eoMyGC5a84OnykTMUROmLIOzXN3TiEEsU --concept 1205166 --file go-release-archive.tgz --output ./release-archive-doi.json --revision 2020-04-23
	```
	success
	```
	time python3 ./scripts/zenodo-version-update.py --verbose --key OJBR7cntKKysaXiWHkoVdwVCZp4eoMyGC5a84OnykTMUROmLIOzXN3TiEEsU --concept 1205159 --file go-release-reference.tgz --output ./release-reference-doi.json --revision 2020-04-23
	```
	success
- [ ] get DOIs and ensure in files as needed
    ```
	cat release-reference-doi.json
	```
    ```json
    {
       "doi": "10.5281/zenodo.3765935"
    }
    ```
    ```
	cat release-archive-doi.json
	```
    ```json
    {
       "doi": "10.5281/zenodo.3765910"
    }
    ```
- [ ] get a working "mount" in place"
	pre:
	```
	scp -i KEY_SKY S3_FILE key2 bbop@build.geneontology.org:/tmp
	```
	main:
    ```
	mkdir -p /tmp/workspace
	```
    ```
	mkdir -p /tmp/workspace/mnt/
	```
    ```
	scp -r -o StrictHostKeyChecking=no -o IdentitiesOnly=true -o IdentityFile=/tmp/KEY_SKY skyhook@skyhook.berkeleybop.org:/home/skyhook/release /tmp/workspace/mnt/
	```
	```
	cp release-archive-doi.json /tmp/workspace/mnt/release/metadata/
	```
    ```
	cp release-reference-doi.json /tmp/workspace/mnt/release/metadata/
	```
- [ ] manual run of release publish stage
  Ready:
  ```
  pip3 install --user filechunkio boto3
  ```
  Get build number: 163
  Get date: 2020-04-23
- [ ] Current:
  ```
  python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory /tmp/workspace/mnt/release --prefix http://current.geneontology.org -x
  ```
  ```
  python3 ./scripts/s3-uploader.py -v --credentials /tmp/aws-go-push.json --directory /tmp/workspace/mnt/release/ --bucket go-data-product-current --number 163 --pipeline release
  ```
- [ ] Release sub-level:
  ```
  python3 ./scripts/directory_indexer.py -v --inject ./scripts/directory-index-template.html --directory /tmp/workspace/mnt/release --prefix http://release.geneontology.org/2020-04-23 -x -u
  ```
  ```
  python3 ./scripts/s3-uploader.py -v --credentials /tmp/aws-go-push.json --directory /tmp/workspace/mnt/release/ --bucket go-data-product-release/2020-04-23 --number 163 --pipeline release
  ```
- [ ] New top-level index.html for release:
  ```
  python3 ./scripts/bucket-indexer.py --credentials /tmp/aws-go-push.json --bucket go-data-product-release --inject ./scripts/directory-index-template.html --prefix http://release.geneontology.org > top-level-index.html
  ```
  ```
  s3cmd -c /tmp/S3_FILE --acl-public --mime-type=text/html --cf-invalidate put top-level-index.html s3://go-data-product-release/index.html
  ```
- [ ] manually run invalidations
  - [ ] current
  - [ ] release, top and inner
- [ ] test
  - [ ] http://current.geneontology.org
  - [ ] http://release.geneontology.org
