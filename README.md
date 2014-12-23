ARF - Adaptive Range Filter
===

Current Status: _Prototype_

An Adaptive Range Filter (ARF) is a tree based data structure
which is to range queries, as a bloom filter is to point queries.

Goals of the ARF:
 - Storage Efficient
 - Efficient Lookup
 - Very low risk of false negatives
 - Less strong guarantee's about false positives.
 - Trained and refined through querying.

This project is an attempt to implement an Adaptive Range Filter in Elixir.

# Resources: #
 - Original paper from Microsoft Research (MSR) on the data structure: [pdf][http://research.microsoft.com/pubs/220613/p1714-kossmann.pdf]
 - Project page for the paper at MSR: [link][http://research.microsoft.com/apps/pubs/default.aspx?id=220613]
