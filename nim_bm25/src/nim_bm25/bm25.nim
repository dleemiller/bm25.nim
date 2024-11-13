import std/algorithm
import bm25_index, tokenizer, math, bm25_types, sequtils

type
  BM25* = object
    index*: InvertedIndex
    docCount*: int
    avgDocLength*: float
    k1*: float
    b*: float

func initBM25*(k1: float = 1.5, b: float = 0.75): BM25 =
  result.index = initInvertedIndex()
  result.docCount = 0
  result.avgDocLength = 0.0
  result.k1 = k1
  result.b = b

proc addDocument*(bm25: var BM25, docId: int, text: string) =
  let tokens = tokenize(text)
  bm25.index.add(docId, tokens)
  bm25.docCount += 1
  bm25.avgDocLength = (bm25.avgDocLength * (bm25.docCount.float - 1.0) + tokens.len.float) / bm25.docCount.float

proc computeScore*(bm25: BM25, query: string, docId: int): float =
  let queryTokens = tokenize(query)
  var score = 0.0
  for token in queryTokens:
    let tf = bm25.index.termFrequency(token, docId).float
    if tf > 0.0:
      let df = bm25.index.documentFrequency(token).float
      let idf = math.ln(1 + (bm25.docCount.float - df + 0.5) / (df + 0.5))
      let denom = tf + bm25.k1 * (1.0 - bm25.b + bm25.b * (bm25.index.docLength(docId) / bm25.avgDocLength))
      score += idf * ((bm25.k1 + 1) * tf) / denom
  return score

proc compareRankedDocuments(a, b: RankedDocument): int =
  return cmp(b.score, a.score)

proc rankDocuments*(bm25: BM25, query: string, docIds: openArray[int]): seq[RankedDocument] =
  var result: seq[RankedDocument] = @[]
  for docId in docIds:
    let score = computeScore(bm25, query, docId)
    result.add((docId: docId, score: score))
  result.sort(compareRankedDocuments)
  return result
