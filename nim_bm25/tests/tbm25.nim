import unittest, nim_bm25

suite "BM25 Library Tests":

  test "Initialization":
    var bm = initBM25()
    check bm.k1 == 1.5
    check bm.b == 0.75
    check bm.docCount == 0
    check bm.avgDocLength == 0.0

  test "Add and Score Document":
    var bm = initBM25()
    bm.addDocument(1, "the quick brown fox")
    bm.addDocument(2, "jumps over the lazy dog")
    check bm.docCount == 2
    check bm.avgDocLength == 4.5

    let score1 = bm.computeScore("quick fox", 1)
    let score2 = bm.computeScore("quick fox", 2)
    check score1 > score2

  test "Rank Documents":
    var bm = initBM25()
    bm.addDocument(1, "Nim is a statically typed compiled systems programming language.")
    bm.addDocument(2, "BM25 is a ranking function used by search engines.")
    bm.addDocument(3, "You'll never get me lucky charms!")

    let query = "search lucky charms"
    let ranked = bm.rankDocuments(query, @[1, 2, 3])

    check ranked.len == 3
    check ranked[0].docId == 3
    check ranked[1].docId == 2
    check ranked[2].docId == 1

