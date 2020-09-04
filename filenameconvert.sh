#!/bin/bash
cd "${1}"/img;
for f in [0-9]-*.jpg;
do mv "${f}" "$(echo "${f}" | sed 's/^/000/')";
done;
for f in [0-9][0-9]-*.jpg;
do mv "${f}" "$(echo "${f}" | sed 's/^/00/')";
done;
for f in [0-9][0-9][0-9]-*.jpg;
do mv "${f}" "$(echo "${f}" | sed 's/^/0/')";
done
