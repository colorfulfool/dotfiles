from typing import List, Optional
import heapq

class Solution:
    def findKthLargest(self, nums: List[int], k: int) -> int:
        heap = []

        for num in nums:
            heapq.heappush(heap, num)

            if len(heap) > k:
                heapq.heappop(heap)

            print(heap)

        return heap[0]
        
if __name__ == "__main__":
	print(Solution().findKthLargest(nums = [3,2,1,5,6,4], k = 2))
