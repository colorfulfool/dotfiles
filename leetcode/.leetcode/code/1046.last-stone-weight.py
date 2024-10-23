from typing import List, Optional
import heapq

class Solution:
    def lastStoneWeight(self, stones: List[int]) -> int:
        stones = [-s for s in stones]

        heapq.heapify(stones)

        while len(stones) > 1:
            y = heapq.heappop(stones)
            x = heapq.heappop(stones)

            if x != y:
                heapq.heappush(stones, y-x)

        return -stones[0] if len(stones) > 0 else 0
        
if __name__ == "__main__":
	print(Solution().lastStoneWeight([2,7,4,1,8,1]))
