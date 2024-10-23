from typing import Counter, List
import heapq

class Pair:
    def __init__(self, freq, word):
        self.freq = freq
        self.word = word

    def __lt__(self, other):
        return self.freq < other.freq or (
            self.freq == other.freq and self.word > other.word)

    def __repr__(self):
        return str(self.freq) + " " + str(self.word)

class Solution:
    def topKFrequent(self, words: List[str], k: int) -> List[str]:
         cnt = Counter(words)
         print(cnt)

         heap = [Pair(freq, word) for word, freq in cnt.items()]
         print(heap)

         return [item.word for item in heapq.nlargest(k, heap)]
        
if __name__ == "__main__": # ["i", "love"]
	print(Solution().topKFrequent(words = ["i","love","leetcode","i","love","coding"], k = 2))
