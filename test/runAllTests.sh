#!/bin/bash

#IMPORTANT Replace with an absolute path to emender-tests
REPO_PATH="/path/to/emender-tests"
ADOC_TEST_DIR=$REPO_PATH"/asciidoctor-tests"
SAMPLE_CONTENT=$REPO_PATH"/test/sample-content"


docker run -ti -v $SAMPLE_CONTENT:/sample-content -v $ADOC_TEST_DIR:/asciidoctor-tests emender-tests /bin/bash -c 'cd /sample-content; emend /asciidoctor-tests/TestAdocLinks.lua --Xmain_file=/sample-content/master.adoc'