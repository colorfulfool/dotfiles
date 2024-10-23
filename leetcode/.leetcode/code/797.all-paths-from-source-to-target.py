from typing import List, Optional

class Solution:
    def allPathsSourceTarget(self, graph: List[List[int]]) -> List[List[int]]:
        ans = []
        
        def helper(node, path):
            if not graph[node]:
                ans.append(path)
                return

            for link in graph[node]:
                helper(link, path + [link])

        helper(0, [0])

        return ans
        
if __name__ == "__main__":
	print(Solution().allPathsSourceTarget([[1,2],[3],[3],[]]))
