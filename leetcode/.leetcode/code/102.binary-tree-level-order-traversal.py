class Solution:
    def levelOrder(self, root: Optional[TreeNode]) -> List[List[int]]:
        ans = []

        def dfs(root, level: int):
            if not root:
                return None

            try:
                ans[level].append(root.val)
            except IndexError:
                ans.append([root.val])

            dfs(root.left, level+1)
            dfs(root.right, level+1)
            return 

        dfs(root, 0)

        return ans
