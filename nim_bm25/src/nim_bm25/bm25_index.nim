import tables, bm25_types, sequtils

type
  InvertedIndex* = object
    index*: Table[string, seq[int]]
    docLengths*: Table[int, int]


proc initInvertedIndex*(): InvertedIndex =
  InvertedIndex(index: initTable[string, seq[int]](), docLengths: initTable[int, int]())

proc add*(self: var InvertedIndex, docId: int, tokens: seq[string]) =
  for token in tokens:
    if self.index.contains(token):
      if self.index[token][high(self.index[token])] != docId:
        self.index[token].add(docId)
    else:
      self.index[token] = @[docId]
  self.docLengths[docId] = tokens.len

proc termFrequency*(self: InvertedIndex, term: string, docId: int): int =
  if not self.index.contains(term):
    return 0
  let postings = self.index[term]
  return count(postings, docId)

proc documentFrequency*(self: InvertedIndex, term: string): int =
  if not self.index.contains(term):
    return 0
  return self.index[term].len

proc docLength*(self: InvertedIndex, docId: int): float =
  if not self.docLengths.contains(docId):
    return 0.0
  return self.docLengths[docId].float
