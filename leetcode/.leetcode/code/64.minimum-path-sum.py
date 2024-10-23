from typing import List, Optional

class Solution:
    def minPathSum(self, grid: List[List[int]]) -> int:
        m, n = len(grid), len(grid[0])

        for i in range(m-1,-1,-1):
            for j in range(n-1,-1,-1):
                if i == m-1 and j == n-1:
                    continue

                if i == m-1:
                    grid[i][j] += grid[i][j+1]
                    continue

                if j == n-1:
                    grid[i][j] += grid[i+1][j]
                    continue

                grid[i][j] += min(grid[i][j+1], grid[i+1][j])

        return grid[0][0]
        
if __name__ == "__main__":
	print(Solution().minPathSum([[1,2,3],[4,5,6]])) # 12
