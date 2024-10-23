from typing import List
from time import sleep

def print_image(image, sr, sc, erase=True):
    if erase:
        print("\x1b[{}F".format(len(image)+1))
    for line in range(len(image)):
        for row in range(len(image[line])):
            if line == sc and row == sr:
                print("\033[1m" + str(image[row][line]) + "\033[0m", end=" ")
            else:
                print(image[row][line], end=" ")
        print("")
    sleep(0.1)

class Solution:
    def floodFill(self, image: List[List[int]], sr: int, sc: int, color: int) -> List[List[int]]:
        self.original_color = image[sr][sc]
        print_image(image, sr, sc, erase=False)

        def helper(sr, sc):
            if sr < 0 or sc < 0 or sr >= len(image) or sc >= len(image[0]):
                return

            if image[sr][sc] != self.original_color or image[sr][sc] == color:
                return

            image[sr][sc] = color
            print_image(image, sr, sc)

            helper(sr, sc-1)
            helper(sr+1, sc)
            helper(sr, sc+1)
            helper(sr-1, sc)

        helper(sr, sc)

        return image

if __name__ == "__main__":
    Solution().floodFill([
        [1,1,1,1,1,1],
        [1,1,1,0,0,0],
        [1,1,0,1,1,1],
        [1,1,0,1,1,0],
        [0,1,0,1,1,0],
        [0,1,0,1,1,0],
    ], 1, 1, 2)
