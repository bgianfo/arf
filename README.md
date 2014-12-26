ARF - Adaptive Range Filter
===

[![Build Status](https://travis-ci.org/bgianfo/arf.svg?branch=master)](https://travis-ci.org/bgianfo/arf)
[![Coverage Status](https://coveralls.io/repos/bgianfo/arf/badge.png?branch=master)](https://coveralls.io/r/bgianfo/arf?branch=master)
[![Doc Status](http://inch-ci.org/github/bgianfo/arf.svg?branch=master)](http://inch-ci.org/github/bgianfo/arf)

<!--[![hex.pm version](https://img.shields.io/hexpm/v/arf.svg?style=flat)](https://hex.pm/packages/arf)-->

Current Status: **Prototype**

An Adaptive Range Filter (ARF) is a tree based data structure which is to range queries, as a bloom filter is to point queries.

Goals of the ARF data structure:
 - Storage Efficient
 - Efficient Lookup
 - Very low risk of false negatives
 - Less strong guarantee's about false positives.
 - Trained and refined through querying.

This project is an attempt to implement an Adaptive Range Filter in Elixir.

# External Resources: #
 - Original paper from Microsoft Research (MSR) describing the data structure: [pdf](http://research.microsoft.com/pubs/220613/p1714-kossmann.pdf)
 - Landing page for the paper: [link](http://research.microsoft.com/apps/pubs/default.aspx?id=220613)
