from typing import List, Optional
from time import sleep

def print_board(board, row, col, suffix, backtrack):
    print("\x1b[5F")
    [print(" ".join(r)) for r in board]
    print((row, col), "∇" if backtrack else "∆", suffix, " "*10)
    sleep(0.3)

class Solution:
    def exist(self, board: List[List[str]], word: str) -> bool:
        def helper(row, col, suffix: str, placeholder: str):
            if row < 0 or row >= len(board):
                return

            if col < 0 or col >= len(board[row]):
                return

            if len(suffix) == 0:
                return True

            if board[row][col] == suffix[0]:
                board[row][col] = placeholder
                print_board(board, row, col, suffix[1:], backtrack = False)                

                if len(suffix) == 1:
                    return True

                top = helper(row-1, col, suffix[1:], "↑")
                right = helper(row, col+1, suffix[1:], "→")
                bottom = helper(row+1, col, suffix[1:], "↓")
                left = helper(row, col-1, suffix[1:], "←")

                if top or bottom or left or right:
                    return True

                board[row][col] = suffix[0]
                print_board(board, row, col, suffix[1:], backtrack = True)                

        for row in range(len(board)):
            for col in range(len(board[row])):
                if helper(row, col, word, "∅"):
                    return True

        return False
        
if __name__ == "__main__":
	print(Solution().exist(
        board = [
            ["A","B","C","E"],
            ["S","F","E","S"],
            ["A","D","E","E"]
        ],
        word = "ABCEFSADEESE"
    ))
