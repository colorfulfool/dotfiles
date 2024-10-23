from typing import List, Optional

class Solution:
    def numIslands(self, grid: List[List[str]]) -> int:
        self.ans = 0

        def helper(row, col):
            if row < 0 or row >= len(grid) or col < 0 or col >= len(grid[row]):
                return

            if grid[row][col] == "1":
                grid[row][col] = "0"

                helper(row-1, col)
                helper(row, col+1)
                helper(row+1, col)
                helper(row, col-1)

        for row in range(len(grid)):
            for col in range(len(grid[row])):
                if grid[row][col] == "1":
                    self.ans += 1
                    helper(row, col)

        return self.ans

if __name__ == "__main__":
    print(Solution().numIslands([
        ["1","1","0","0","0"],
        ["1","1","0","0","0"],
        ["0","0","1","0","0"],
        ["0","0","0","1","1"]
    ]))
